/**
 * @return {string}
 */
function GetIdValue(id) {
    let Value = "";
    let element = document.getElementById(id);
    if (element != null) {
        if (element.nodeName === "INPUT") {
            Value = element.value;
        } else {
            Value = element.innerText;
        }
    } else {
        console.log("element is null");
    }
    return Value;
}

/**
 * @return {string}
 */
function JOBStrGet(JOB, Key) {
    return JOBStrGetInit(JOB, Key, "");
}

function JOBStrGetInit(JOB, Key, InitVal) {
    let Value = InitVal;
    if (JOB != null) {
        if (Key in JOB) {
            Value = JOB[Key];
        }
    }
    return Value;
}


/**
 * @return {number}
 */
function JOBNumGet(JOB, Key) {
    let Value = 0;
    if (Key in JOB) {
        Value = JOB[Key];
    }
    return Value;
}


function JAStrGet(Str) {
    let JA = JSON.parse("[]");
    if (Str != null && Str.length > 2) {
        JA = JSON.parse(Str);
        if (JA == null) JA = JSON.parse("[]");
    }
    return JA;
}

function GetJOB(Str) {
    let JOB = JSON.parse("{}");
    if (Str != null && Str.length > 2) {
        try {
            JOB = JSON.parse(Str);
        } catch (e) {
            console.log(e.toString());
        }
    }
    return JOB;
}

function SAlert(Title, Content = "") {
    Swal.fire({
        title: '<p class="text-2xl">' + Title + '</p>',
        text: Content,
        heightAuto: false
    });
}

function SSuccess(Title, Content = "") {
    Swal.fire({
        title: '<p class="text-2xl">' + Title + '</p>',
        text: Content,
        icon: 'success',
        showConfirmButton: false,
        heightAuto: false
    });
}


function SHtml(Title, Html = "") {
    Swal.fire({
        title: '<p class="text-2xl">' + Title + '</p>',
        html: Html,
        heightAuto: false,
    });
}

function SAsk(Title, Content = "", Settings = {}) {
    return swal.fire({
        title: '<p class="text-2xl">' + Title + '</p>',
        text: Content,
        heightAuto: false,
        confirmButtonColor: isApp() ? "#E17666" : "#10B981",
        allowOutsideClick: JOBStrGetInit(Settings, "CancelAble", true),
        confirmButtonText: JOBStrGetInit(Settings, "Confirm", "確認"),
        cancelButtonText: JOBStrGetInit(Settings, "Cancel", "取消"),
        showCancelButton: JOBStrGetInit(Settings, "ShowCancel", true),
    });
}

let SProgressID = 0;

/**
 * @return {number}
 */
function SProgress(Title) {
    SProgressID = Math.random() * 1000;
    Swal.fire({
        title: Title,
        timerProgressBar: true,
        showConfirmButton: false,
        heightAuto: false,
        willOpen: () => {
            Swal.showLoading();
        }
    });
    return SProgressID;
}

function SProgressC(PID) {
    if (SProgressID !== 0 && PID === SProgressID) {
        Swal.close();
        SProgressID = 0;
    }
}

function GetEID(ID, Element) {
    if (Element != null) {
        return Element.querySelector("#" + ID);
    } else {
        return document.getElementById(ID);
    }
}

function GetCookieWeb(Key) {
    let Val = Cookies.get(Key);
    return Val != null ? Val : "";
}

function SetCookieWeb(Key, Value) {
    return Cookies.set(Key, Value, {expires: 30});
}

//這邊代替為App內的 SharedPreferences
async function GetCookie(Key) {
    if (isApp()) {
        let value = await CallAppFuncCB("getSPValue", Key);
        if (typeof value === "string") return value;
    } else {
        return GetCookieWeb(Key);
    }
    return ""
}

async function SetCookie(Key, Value) {
    if (isApp()) await CallAppFunc("setSPValue", Key, Value);
    else SetCookieWeb(Key, Value);
}

function GetStorageWeb(Key) {
    return new Promise((resolve, reject) => {
        localforage.getItem(Key).then(function (value) {
            resolve(value)
        }).catch(function (err) {
            // 当出错时，此处代码运行
            console.log(err);
            reject();
        });
    });
}

function SetStorageWeb(Key, Value) {
    return new Promise((resolve, reject) => {
        localforage.setItem(Key, Value).then(function (value) {
            resolve(value);
        }).catch(function (err) {
            console.log(err);
            //Clear DB
            localforage.clear().then(function () {
                // 当数据库被全部删除后，此处代码运行
                console.log('Database is now empty.');
            }).catch(function (err) {
                console.log(err);
            });
            reject();
        });
    });
}

//這邊代替為App內的 SharedPreferences
function GetStorage(key) {
    return new Promise(async (resolve) => {
        let value = await GetCookie(key);
        //嘗試自動解析
        try {
            value = JSON.parse(value.toString());
        } catch (e) {
            console.log(e.stack);
        }
        resolve(value);
    });
}

function SetStorage(key, value) {
    //自動判斷儲存類型
    let saveVal = "";
    if (typeof value === "object") {
        saveVal = JSON.stringify(value);
    } else if (typeof value !== "string") {
        saveVal = value.toString();
    }

    return new Promise((resolve) => {
        SetCookie(key, saveVal);
        resolve(value);
    });
}

function SetTmpData(JOB) {
    return Cookies.set("TmpData", JSON.stringify(JOB));
}

function GetTmpData() {
    return JSON.parse(Cookies.get("TmpData"));
}

function ClassAdder(element, value, force = false) {
    if (!element.className.includes(value) || force) element.classList.add(value);
}

function ClassRemover(element, value) {
    if (element.className.includes(value)) element.classList.remove(value);
}

function CloneEl(element) {
    return element.cloneNode(true);
}

function SortDate(InfoJA, Key, Order) {
    InfoJA.sort(function (JOB_A, JOB_B) {
        // Turn your strings into dates, and then subtract them
        // to get a value that is either negative, positive, or zero.
        if (Order === "ASC") return new Date(JOB_A[Key]) - new Date(JOB_B[Key]);
        else return new Date(JOB_B[Key]) - new Date(JOB_A[Key]);
    });
}

function SortTime(InfoJA, Key, Order) {
    InfoJA.sort(function (JOB_A, JOB_B) {
        // Turn your strings into dates, and then subtract them
        // to get a value that is either negative, positive, or zero.
        if (Order === "ASC") return JOB_A[Key] - JOB_B[Key];
        else return JOB_B[Key] - JOB_A[Key];
    });
}

/**
 * @return {string}
 */
function GetDate(Time, Divider = "/") {
    let date = new Date(Time * 1000);
    return AFN(date.getFullYear()) + Divider + AFN(date.getMonth() + 1) + Divider + AFN(date.getDate());
}

/**
 * @return {string}
 */
function GetDateYM(Time, Divider = "/") {
    let date = new Date(Time * 1000);
    return AFN(date.getFullYear()) + Divider + AFN(date.getMonth() + 1);
}

/**
 * @return {string}
 */
function GetTime(Time, Sec = true) {
    let date = new Date(Time * 1000);
    let TimeShow = AFN(date.getHours()) + ":" + AFN(date.getMinutes());
    if (Sec) TimeShow += ":" + AFN(date.getSeconds());
    return TimeShow;
}

/**
 * @return {string}
 */
function GetDateTime(Time) {
    let date = new Date(Time * 1000);
    let DateTime = AFN(date.getFullYear()) + "/" + AFN(date.getMonth() + 1) + "/" + AFN(date.getDate());
    DateTime += " " + AFN(date.getHours()) + ":" + AFN(date.getMinutes()) + ":" + AFN(date.getSeconds());
    return DateTime;
}

function GetCTime() {
    let today = new Date();
    return AFN(today.getHours()) + ":" + AFN(today.getMinutes()) + ":" + AFN(today.getSeconds());
}

/**
 * @return {string}
 */
function AFN(Val, AF = 2) {
    let ValStr = String(Val);
    while (ValStr.length < AF) ValStr = "0" + ValStr;
    return ValStr;
}

function ShowDivRight(Show) {
    if (Show) $('#divRight').fadeIn(500);
    else $('#divRight').fadeOut(100);
}

/**
 * @return {boolean}
 */
function ContainUser(InfoJOB, Keyword) {
    let MemID = InfoJOB["MemID"];
    let Account = InfoJOB["Account"];
    let Name = InfoJOB["Name"];
    //Search or all
    let ContainValue = false;
    if (Keyword.length > 0) {
        if (MemID != null && MemID.toLowerCase().includes(Keyword)) ContainValue = true;
        else if (Account != null && Account.toLowerCase().includes(Keyword)) ContainValue = true;
        else if (Name != null && Name.toLowerCase().includes(Keyword)) ContainValue = true;
    } else {
        ContainValue = true;//Show All Data
    }
    return ContainValue;
}

function GetRandStr(Len = 5) {
    let RandStr = "";
    for (let cnt = 0; cnt < Len; cnt++) {
        RandStr += (Math.floor(Math.random() * 10)).toString();
    }
    return RandStr;
}

//Time==================================================================================================================
function GetCurrentM() {
    return new Date().getTime();
}

function MsToTime(duration) {
    let seconds = Math.floor((duration / 1000) % 60),
        minutes = Math.floor((duration / (1000 * 60)) % 60),
        hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

    hours = (hours < 10) ? "0" + hours : hours;
    minutes = (minutes < 10) ? "0" + minutes : minutes;
    seconds = (seconds < 10) ? "0" + seconds : seconds;

    return hours + ":" + minutes + ":" + seconds;
}


async function ResizeImageFile(file, max_size) {
    const img = document.createElement('img');
    // create img element from File object
    img.src = await new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target.result);
        reader.readAsDataURL(file);
    });
    await new Promise((resolve) => {
        img.onload = resolve;
    });
    return ResizeImage(img, max_size);
}

// Takes a data URI and returns the Data URI corresponding to the resized app.image at the wanted size.
async function ResizeImageBase64(data, max_size, square = false) {
    const img = document.createElement('img');
    img.src = data;
    await new Promise((resolve) => {
        img.onload = resolve;
    });
    if ((img.width > max_size || img.height > max_size) || (square && img.width !== img.height)) {
        return ResizeImage(img, max_size, square);//需要壓縮 or 調整
    } else {
        return data;//不用壓縮
    }
}

function ResizeImage(img, max_size, square = false) {
    let canvas = document.createElement('canvas');
    let width = img.width;
    let height = img.height;
    let StartX = 0, StartY = 0;
    let CanvasW = 0, CanvasH = 0;
    //Scale
    if (width > height) {
        if (width > max_size) {
            height *= max_size / width;
            width = max_size;
        }
    } else {
        if (height > max_size) {
            width *= max_size / height;
            height = max_size;
        }
    }
    //Check square settings
    if (square) {
        //Check Start Point & Set square
        if (width > height) {
            StartY = (width - height) / 2;
            CanvasW = width;
            CanvasH = width;
        } else if (height > width) {
            StartX = (height - width) / 2;
            CanvasW = height;
            CanvasH = height;
        }
    } else {
        CanvasW = width;
        CanvasH = height;
    }
    // We set the dimensions at the wanted size.
    canvas.width = CanvasW;
    canvas.height = CanvasH;
    // We resize the app.image with the canvas method drawImage();
    canvas.getContext('2d').drawImage(img, StartX, StartY, width, height);
    return canvas.toDataURL('app.image/png', 0.7);
}

// Takes a data URI and returns the Data URI corresponding to the resized app.image at the wanted size.
async function ResizeImageBase64Width(data, maxWidth) {
    const img = document.createElement('img');
    img.src = data;
    await new Promise((resolve) => {
        img.onload = resolve;
    });
    if (img.width > maxWidth) {
        return ResizeImageWidth(img, maxWidth);//需要壓縮 or 調整
    } else {
        return data;//不用壓縮
    }
}

function ResizeImageWidth(img, maxWidth) {
    let canvas = document.createElement('canvas');
    let width = img.width;
    let height = img.height;
    let StartX = 0, StartY = 0;
    //Scale
    height *= maxWidth / width;
    width = maxWidth;
    // We set the dimensions at the wanted size.
    canvas.width = width;
    canvas.height = height;
    // We resize the app.image with the canvas method drawImage();
    canvas.getContext('2d').drawImage(img, StartX, StartY, width, height);
    return canvas.toDataURL('app.image/png', 0.7);
}

function delay(Millis) {
    return new Promise(resolve => {
        setTimeout(() => {
            resolve();
        }, Millis);
    });
}

function GetParam(Params, Name) {
    return Params.has(Name) ? Params.get(Name) : "";
}

function GetParamsStr(Params) {
    let ParamStr = "";
    if (Array.from(Params).length > 0) {
        ParamStr = "?" + Params.toString();
    }
    return ParamStr;
}

function maxLengthCheck(object) {
    if (object.value.length > object.maxLength)
        object.value = object.value.slice(0, object.maxLength)
}

function ConvertToPrism(deg, decNum = 0) {//角度，小數位
    let dec = Math.pow(10, decNum);
    let radians = Math.abs(deg) * (Math.PI / 180);
    return Math.round(32 * Math.sin(radians) * dec) / dec;
    // return Math.round(32 * Math.sin(radians) * 10) / 10;//小數1位
}

function ConvertToDegree(prism) {
    return Math.abs(Math.round(Math.asin(Math.abs(prism) / 32) / (Math.PI / 180)));
}

function isNetAvailable() {
    return navigator.onLine;
}

function isServerAvailable(url) {
    let xhr = new XMLHttpRequest();
    // xhr.timeout = 2000; // 超时时间，单位是毫秒
    xhr.open("GET", url, false);
    xhr.send(null);
    return xhr.status === 200;
}

function fileDownloader(url, filename) {
    return new Promise((resolve, reject) => {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.responseType = "blob";
        xhr.timeout = 60000;
        xhr.onload = function () {
            if (xhr.status && xhr.status === 200) {
                let fileReader = new FileReader();
                fileReader.onload = function (evt) {
                    let result = evt.target.result;
                    try {
                        // noinspection JSCheckFunctionSignatures
                        localStorage.setItem(filename, result);
                        resolve("T");
                    } catch (e) {
                        reject("Storage failed: " + e);
                    }
                };
                fileReader.readAsDataURL(xhr.response);
            } else {
                reject(xhr.response);
            }
        }
        xhr.send();
    })
}

//App===================================================================================================================
function isApp() {
    let isApp = false;
    if (window.JS != null) isApp = true;//Android
    else if (window.webkit != null && window.webkit.messageHandlers != null) isApp = true;//iOS
    // if (!isApp) SAlert("未偵測到JSInterface");
    return isApp;
}

let autoResolve = false;
let resolveName;
let resolveFunc;//回調時需要呼叫的方法

//func name,value 1,value 2
function CallAppFunc() {
    autoResolve = isIOS();
    CallAppFuncCB.apply(null, arguments).finally(function () {
        autoResolve = false;
    });
}

function CallAppFuncCB() {
    return new Promise((resolve, reject) => {
        if (isApp()) {
            if (isAndroid()) {
                let name = "";
                try {
                    let args = Array.prototype.slice.call(arguments);
                    name = args[0];//取得Android端JS名稱
                    args.splice(0, 1);//移除此參數
                    if (args.length === 0) resolve(window["JS"][name]());
                    else if (args.length === 1) resolve(window["JS"][name](args[0]));
                    else if (args.length === 2) resolve(window["JS"][name](args[0], args[1]));
                    else reject("Unknown args len");
                    //Socket log
                    if (name === "sendMsg") SLog("功能:" + name);
                    else SLog("功能: " + name + " 參數: " + args.toString());
                } catch (e) {
                    console.log("CallAppFuncCB Name: " + name);
                    reject(e.stack)
                }
            } else if (isIOS()) {
                let args = Array.prototype.slice.call(arguments);
                let name = args[0];//取得iOS端JS名稱
                args.splice(0, 1);//移除此參數
                let SendJOB = {
                    callback: "iOSCallBackHandler",
                    name: name,
                    argus: args
                }
                //判斷Auto resolve
                resolveName = autoResolve ? null : name;
                resolveFunc = autoResolve ? null : resolve;
                //Post
                window["webkit"]["messageHandlers"]["JS"].postMessage(JSON.stringify(SendJOB));
                //Auto resolve
                if (autoResolve) resolve();
                //Log
                if (name === "sendMsg") SLog("功能:" + name);
                else SLog("功能:" + name + " 參數:" + args.toString());
            } else {
                SAlert("發生呼叫錯誤", "未知系統類型");
                reject("Unknown system type");
            }
        } else {
            SAlert("發生呼叫錯誤", "偵測到不是App");
            reject("Not App error");
        }
    });
}

//用於iOS回傳參數
function iOSCallBackHandler(name, value) {
    if (resolveName != null) {
        if (resolveName === name) {
            resolveFunc(value);
        } else {
            console.log(GetCTime() + " 無效的回應", "resolveName: " + resolveName + " name: " + name);
        }
        resolveName = null;
    }
}

function isIOS() {
    let UA = navigator.userAgent;
    return UA.includes("YEN/iOS");
}

function isAndroid() {
    let UA = navigator.userAgent;
    return UA.includes("YEN/Android");
}

//Fetch
let FetchPID = 0;
const MApiUrl = location.protocol + "//" + location.hostname + "/api/";

function SFetchClient(CallBack, ApiName, SendJOB, SettingJOB = {}, ErrCallBack = null) {
    setTimeout(async function () {
        //Handle Progress
        let timeoutID = setTimeout(function () {
            let ShowProgress = JOBStrGetInit(SettingJOB, "ShowProgress", "T");
            if (ShowProgress === "T") FetchPID = SProgress("處理中");
        }, 500);
        //Prepare Data
        SendJOB["ApiName"] = ApiName;
        SendJOB["token"] = await GetCookie("token");
        //Get Fetch Setting
        let ErrAlert = JOBStrGetInit(SettingJOB, "ErrAlert", "T");
        let ApiUrl = MApiUrl + JOBStrGetInit(SettingJOB, "ApiUrl", "api_client.php");
        //Prepare Fetch
        let XHR = new XMLHttpRequest();
        XHR.onreadystatechange = function () {
            try {
                if (this.readyState === 4) SFetchClientHandler(this, timeoutID, CallBack, ApiName, ErrCallBack);
            } catch (e) {
                console.log(e.stack);
                console.log(this.responseText);
                if (ErrAlert === "T") SAlert("發生意外錯誤", e.message);
            }
        };
        //Post
        XHR.open("POST", ApiUrl, true);
        XHR.send(JSON.stringify(SendJOB));
    }, 0)
}

function SFetchClientHandler(XHR, timeoutID, CallBack, ApiName, ErrCallBack) {
    try {
        //Reset Progress Handle
        window.clearTimeout(timeoutID);
        SProgressC(FetchPID);//Close
        //Process Result
        if (XHR.status === 200) {
            let ResJOB = JSON.parse(XHR.responseText);
            let ResCode = JOBStrGet(ResJOB, "ResCode");
            let ResMsg = JOBStrGet(ResJOB, "ResMsg");
            let FetchSuccess = false;
            if (ResCode === "LI") {
                SAlert("伺服器偵測到缺少資訊", ApiName);
                console.log(ResMsg);
            } else if (ResCode === "NF") {
                SAlert("伺服器偵測到錯誤", "呼叫了錯誤的方法: " + ResMsg);
            } else if (ResCode === "SQL") {
                SAlert("資料庫錯誤", ResMsg);
            } else if (ResCode === "SC") {
                SAlert(ApiName + " 包含問題字元", "您的請求可能包含了符號 \' ，請移除此符號");
            } else if (ResCode === "NP") {
                SAlert("您的權限不足", "請先登出後更換帳戶");
            } else if (ResCode === "AF") {
                SAlert("您的權限不足");
            } else if (ResCode === "NA") {//伺服器不允許連入
                top.location = "/Pages/app/html/NotAllow.html"
            } else {
                FetchSuccess = true;
                CallBack(ResJOB);
            }
            //ErrCallBack
            if (!FetchSuccess) ErrCallBackHandler(ErrCallBack, ResCode, ResMsg);
        } else {
            ErrCallBackHandler(ErrCallBack, "status", XHR.status.toString());
            SAlert("網路連線發生錯誤", "Status: " + XHR.status + " content: " + XHR.statusText + "\nresponse: " + XHR.responseText);
        }
    } catch (e) {
        console.log(e.stack);
        console.log(XHR.responseText);
        ErrCallBackHandler(ErrCallBack, "catch", e.stack.toString());
    }
}

function SFetchConsole(CallBack, ApiName, SendJOB, SettingJOB = {}, ErrCallBack = null) {
    SettingJOB["ApiUrl"] = "api_console.php";
    SFetchClient(CallBack, ApiName, SendJOB, SettingJOB, ErrCallBack);
}

function ErrCallBackHandler(ErrCallBack, ResCode = "", ResMsg = "") {
    if (typeof ErrCallBack == "function") ErrCallBack(ResCode, ResMsg);
}

function GetAppOS() {
    let userAgent = navigator.userAgent;
    if (userAgent.includes("Android")) return "Android";
    else if (userAgent.includes("iOS")) return "iOS";
    else return "Unknown";
}

function GetDomainUrl() {
    return window.location.protocol + "//" + window.location.hostname + "/";
}

async function isDeviceConnected() {
    let isDeviceConnectedStr = await CallAppFuncCB("isDeviceConnected");
    let isDeviceConnectedJOB = JSON.parse(isDeviceConnectedStr.toString());
    return JOBStrGet(isDeviceConnectedJOB, "isDeviceConnected") === "T";
}

function SLog(msg) {
    let deviceSystem = isAndroid() ? "Android: " : "iOS: ";
    let time = GetCTime();
    // SLogAS(time + " " + deviceSystem + msg).then();
}

async function SLogAS(msg) {
    SVSendMsg("Set_Log", msg);
}

function addHours(date, hours) {
    let result = new Date(date);
    result.setHours(result.getHours() + hours);
    return result;
}

function isNumeric(str) {
    if (typeof str != "string") return false // we only process strings!
    return !isNaN(str) && // use type coercion to parse the _entirety_ of the string (`parseFloat` alone does not do this)...
        !isNaN(parseFloat(str)) // ...and ensure strings of whitespace fail
}

function getLocation(callback) {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(callback);
    } else {
        callback(null);
    }
}

function base64ToByteArray(base64) {
    let binary_string = atob(base64.split(",")[1]);
    let len = binary_string.length;
    let bytes = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
        bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
}

function byteArrayToBase64(buffer) {
    let binary = '';
    let bytes = new Uint8Array(buffer);
    let len = bytes.byteLength;
    for (let i = 0; i < len; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    return window.btoa(binary);
}