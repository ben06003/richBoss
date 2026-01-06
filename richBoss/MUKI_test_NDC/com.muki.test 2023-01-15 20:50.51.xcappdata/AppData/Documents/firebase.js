//FireBase
function FirebaseInit() {
    const firebaseConfig = {
        apiKey: "AIzaSyBIVZuEKtmU51e1aCMcxkl0FKIaiBb_5rM",
        authDomain: "customer-2018.firebaseapp.com",
        databaseURL: "https://customer-2018.firebaseio.com",
        projectId: "customer-2018",
        storageBucket: "customer-2018.appspot.com",
        messagingSenderId: "645087077696",
        appId: "1:645087077696:web:46589b82073268047686a5",
        measurementId: "G-4P434XBC2Q"
    };

    // Initialize Firebase
    firebase.initializeApp(firebaseConfig);
}


function FirebaseSignInListener(callback) {
    firebase.auth().onAuthStateChanged(function (user) {
        if (user) {
            user.getIdToken().then(function (accessToken) {
                //provider
                let providerData = user.providerData;
                let providerJOB = providerData[0];
                let providerId = providerJOB["providerId"];
                //callback
                callback(true, user, accessToken, providerId);
            });
        } else {//SignOut
            callback(false, user);
        }
    }, function (error) {
        SAlert("發生錯誤:", error);
    });
}

function FirebaseSignOut() {
    firebase.auth().signOut().then(async () => {
        console.log("User SignOut Success");
        //Clear All Cookie Data
        await SetCookie("token", "");
        await SetCookie("displayName", "");
        setTimeout(function () {
            top.location.href = "/index.html";//回到初始頁面
        }, 500);
    }).catch((error) => {
        SAlert("發生錯誤:", error);
    });
}