window.onload = function () {
    FirebaseInit();
    FirebaseUIHandler();
    FirebaseSignInHandler();
}

function FirebaseUIHandler() {
    // FirebaseUI config. 設定參考這裡 https://github.com/firebase/firebaseui-web
    let uiConfig = {
        signInFlow: 'redirect',
        signInSuccessUrl: GetDomainUrl() + "app/html/Page_Login.html",
        signInOptions: [
            // Leave the lines as is for the providers you want to offer your users.
            firebase.auth.GoogleAuthProvider.PROVIDER_ID,
            // firebase.auth.FacebookAuthProvider.PROVIDER_ID,
            firebase.auth.EmailAuthProvider.PROVIDER_ID,
        ],
        tosUrl: GetDomainUrl() + 'app.html/Page_Mine_Privacy.html?ShowHeader=T',
        privacyPolicyUrl: GetDomainUrl() + 'app.html/Page_Mine_Privacy.html?ShowHeader=T',
        callbacks: {
            //https://firebase.google.com/docs/reference/android/com/google/firebase/auth/FirebaseUser
            signInSuccessWithAuthResult: function (authResult, redirectUrl) {
                // let user = authResult.user;
                // let credential = authResult.credential;
                // let isNewUser = authResult.additionalUserInfo.isNewUser;
                // let providerId = authResult.additionalUserInfo.providerId;
                // let operationType = authResult.operationType;
                return false;
            },
            uiShown: function () {

            }
        },
    };

    // Initialize the FirebaseUI Widget using Firebase.
    let ui = new firebaseui.auth.AuthUI(firebase.auth());
    // The start method will wait until the DOM is loaded.
    ui.start('#firebaseui-auth-container', uiConfig);
}


function FirebaseSignInHandler() {
    FirebaseSignInListener(async (signIn, user, accessToken, providerId) => {
        if (signIn) {
            // User is signed in.
            let emailVerified = user.emailVerified;
            //provider
            if (providerId === "password" && !emailVerified) {
                user.sendEmailVerification();
                GetEID("pHint").innerText = "請先驗證您的Email再重新登入\n驗證信已經發送至您的信箱";
                let btFunc = GetEID("btFunc");
                btFunc.innerText = "我已驗證完成";
                btFunc.addEventListener('click', function () {
                    location.reload();
                });
                ClassAdder(GetEID("firebaseui-auth-container"), "hidden");//隱藏登入功能
                ClassRemover(btFunc, "hidden");
            } else {
                GetEID("pHint").innerText = "登入作業處理中，請稍後...";
                ClassAdder(GetEID("firebaseui-auth-container"), "hidden");//隱藏登入功能
                Get_Login(providerId, user, accessToken);
            }
        } else {//已登出
            GetEID("pHint").innerText = "選擇一種常用的方式快速登入";
            ClassRemover(GetEID("firebaseui-auth-container"), "hidden");//顯示登入功能
            //Clear All Cookie Data
            await SetCookie("token", "");
            await SetCookie("name", "");
            await SetCookie("photo", "");
        }
    })
}


//Network===============================================================================================================
function Get_Login(providerId, user, accessToken) {
    //Read Info
    let name = user.displayName;
    let email = user.email;
    let photoURL = user.photoURL;
    let uid = user.uid;
    let phone = user.phoneNumber;
    let password = md5(accessToken);
    //Get High Resolution Photo
    if (providerId.includes('google')) {
        photoURL = photoURL.replace('s96-c', 's400-c');
    } else if (providerId.includes('facebook')) {
        photoURL = `${photoURL}?type=large`;
    }
    if (uid.length > 0 && password.length > 0) {//登入之後才能詢問
        //UserAgent
        let UserAgent = navigator.userAgent;
        //Prepare
        let SendJOB = {
            uid: uid,
            password: password,
            name: name,
            email: email,
            phone: phone,
            photoURL: photoURL,
            userAgent: UserAgent,
            provider: providerId
        };
        SFetchClient(async function (ResJOB) {
            let SAskSetting = {Confirm: "確認", Cancel: "取消", ShowCancel: false};
            let ResCode = JOBStrGet(ResJOB, "ResCode");
            let ResMsg = JOBStrGet(ResJOB, "ResMsg");
            if (ResCode === "1" || ResCode === "3") {//Login Success || Register Success
                let InfoJOB = ResJOB["InfoJOB"];
                //Save
                await SetCookie("token", JOBStrGet(InfoJOB, "token"));
                await SetCookie("name", JOBStrGet(InfoJOB, "name"));
                await SetCookie("photo", JOBStrGet(InfoJOB, "photo"));
                //GoPage
                if (isApp()) {//Go welcome
                    //自動連接裝置
                    let delay = 0;
                    if (!await isDeviceConnected()) {
                        let macAddress = await GetCookie("macAddress");
                        if (macAddress != null && macAddress.length > 0) {
                            CallAppFunc("connectDevice", macAddress);
                            delay = 1000;
                        }
                    }
                    //前往歡迎頁
                    setTimeout(() => {
                        location.href = "/app/html/Page_Welcome.html";
                    }, delay)
                } else location.href = "/console";//Go console
            } else if (ResCode === "2") {
                SAsk("登入發生錯誤", "更新資料庫失敗\n" + ResMsg, SAskSetting).then(result => {
                    if (result.value) location.reload();
                });
            } else if (ResCode === "4") {
                SAsk("登入發生錯誤", "新增資料庫失敗\n" + ResMsg, SAskSetting).then(result => {
                    if (result.value) location.reload();
                });
            } else {
                SAsk("登入發生錯誤", "ResCode: " + String(ResCode) + "\n" + ResMsg, SAskSetting).then(result => {
                    if (result.value) location.reload();
                });
            }
            //Firebase SignOut
            if (!(ResCode === "1" || ResCode === "3")) FirebaseSignOut("/app/html/Page_Login.html");
        }, "Get_Login", SendJOB);
    } else {
        SAlert("登入發生錯誤", "資料缺失");
    }
}