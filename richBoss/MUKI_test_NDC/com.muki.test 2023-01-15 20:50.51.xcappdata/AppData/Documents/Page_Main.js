let iFramePreUrl = "";//iFrame上一頁的網址
let ifMain;
//Func
let isPageLoaded = false;

window.onload = function () {
    CallAppFunc("setOrientation", "portrait");//設為直立模式
    // new VConsole();
    isPageLoaded = true;
    if (isApp()) IndexSetup().then();
}

//ViewHandler===========================================================================================================
async function IndexSetup() {
    //Check is App
    if (!isApp()) {
        location.href = "/app/html/Page_NotSupport.html";
        return;
    }
    //Get iFrame
    ifMain = GetEID("ifMain");
    //Param
    let ParseURL = new URL(window.location.href);
    let Params = ParseURL.searchParams;
    let UrlGoPage = GetParam(Params, "GoPage");
    //Other Params
    if (UrlGoPage.length > 0) {
        await iframeHref("/app/html/" + UrlGoPage);
    } else {
        GoPage("Page_Home");
    }
    //Handle View
    await IndexViewHandler();
    //Set Up iFrame
    let iframeMain = GetEID("ifMain");
    iframeURLChangeListener(iframeMain, function () {//有參數 newURL
        //這邊判斷是用於可能SMethods還沒完成載入
        if (isPageLoaded && typeof CallAppFunc === "function") CallAppFunc("sProgress", "Loading...");
    });
    GetEID("ifMain").style.visibility = "visible";//用來讓 noscript時不顯示
    //監聽裝置連線狀態
    preConnected = await isDeviceConnected();//更新至目前狀態
    DeviceConnectionChecker().then();
    //Socket Service
    InitSocketLogService();
}

async function IndexViewHandler() {
    let develop = await GetCookie("Develop");
    //Set App 為開發者模式
    if (isAndroid()) CallAppFunc("setDevelopMode", develop);
    //NetMode Mode
    let netMode = await GetCookie("netMode");
    if (netMode === "Offline") {
        ClassRemover(GetEID("pNetMode"), "hidden");
    }
}

//Header & Foot=========================================================================================================
let headerShow = false, footerShow = true;

function iFrameSizeHandler() {
    //iFrame Size
    let minusVal;
    if (headerShow && footerShow) minusVal = "110";
    else if (headerShow && !footerShow) minusVal = "50";
    else if (!headerShow && footerShow) minusVal = "60";
    else minusVal = "0";
    //Resize
    let divIframe = GetEID("divIframe");
    divIframe.style.minHeight = "calc(100% - " + minusVal + "px)";
    divIframe.style.maxHeight = "calc(100% - " + minusVal + "px)";
}


//Header================================================================================================================
let headerFunc;

function SetHeaderInfo(title, func = null, mode = 1) {
    //Title
    if (title.length > 0) {//顯示標題欄
        headerShow = true;
        GetEID("pTitle").innerText = title;
        ClassRemover(GetEID("divHeader"), "hidden");
    } else {//隱藏標題欄
        headerShow = false;
        ClassAdder(GetEID("divHeader"), "hidden");
    }
    //Func
    let imgFunc = GetEID("imgFunc");
    if (func != null) {
        headerFunc = func;
        ClassRemover(imgFunc, "hidden");
    } else {
        ClassAdder(imgFunc, "hidden");
    }
    //mode
    if (mode === 1) {//白底 & 綠箭頭 模式
        ClassAdder(GetEID("divHeader"), "bg-white");
        imgFunc.src = "/common/image/ic_back_green.png"
    } else if (mode === 2) {//透明底 & 紅箭頭 模式
        ClassRemover(GetEID("divHeader"), "bg-white");
        imgFunc.src = "/common/image/ic_back_red.png"
    }
    //iFrame Size
    iFrameSizeHandler();
}

function callHeaderFunc() {
    if (typeof headerFunc === "function") headerFunc();
}

function refreshIFPage() {
    ifMain.contentWindow.location.reload();
}

//Foot==================================================================================================================
function SetFooterShow(show) {
    footerShow = show;
    if (show) {
        $("#divFoot").fadeIn(300, () => {
            iFrameSizeHandler(); //iFrame Size
        })
    } else {
        $("#divFoot").fadeOut(300, () => {
            iFrameSizeHandler(); //iFrame Size
        })
    }
}

//iFrame================================================================================================================
function iframeURLChangeListener(iframe, callback) {
    let lastDispatched = null;
    let dispatchChange = function () {
        let newHref = iframe.contentWindow.location.href;
        if (newHref !== lastDispatched) {
            if (typeof callback === "function") callback(newHref);
            lastDispatched = newHref;
        }
    };
    let unloadHandler = function () {
        // Timeout needed because the URL changes immediately after
        // the `unload` event is dispatched.
        iFramePreUrl = iframe.contentWindow.location.href;
        setTimeout(dispatchChange, 0);
    };

    function attachUnload() {
        // Remove the unloadHandler in case it was already attached.
        // Otherwise, there will be two handlers, which is unnecessary.
        iframe.contentWindow.removeEventListener("unload", unloadHandler);
        iframe.contentWindow.addEventListener("unload", unloadHandler);
    }

    iframe.addEventListener("load", function () {
        attachUnload();
        // Just in case the change wasn't dispatched during the unload event...
        dispatchChange();
    });
    attachUnload();
}

//iFrame
let RunGoPageHandler = true;//用來讓此功能在每個頁面正確執行1次

async function iframeHref(GoUrl) {
    try {
        let availableChange = false;
        if (isAndroid()) {
            let netMode = await GetCookie("netMode");
            //Check Network
            // let appInfo = await CallAppFuncCB("getAppInfo");
            // let resJOB = JSON.parse(appInfo.toString());
            // let appVersion = JOBNumGet(resJOB, "AppVersion");
            let haveCache = await CallAppFuncCB("getSPValue", "haveCache");
            //Check availableChange
            if (netMode === "Online") {
                if (isNetAvailable()) availableChange = true;
                else SAlert("網絡連接已斷開", "請先確認您的網絡連線正常");
            } else {//Offline Mode
                if (haveCache) availableChange = true;
                else SAlert("網絡連接已斷開", "請先確認您的網絡連線正常");
            }
        } else if (isIOS()) {
            availableChange = true;
        } else {
            SAlert("更換頁面遇到問題", "請確認您使用的環境為App");
        }

        //Change page
        if (availableChange) {
            $("#ifMain").fadeOut(300, function () {
                GoPageHandler(GoUrl);//讀取前要放 因為FBPixel會讀網址
                RunGoPageHandler = false;
                GetEID("ifMain").src = GoUrl;
            });
        }
    } catch (e) {
        SAlert("跳轉頁面發生錯誤", e.stack);
    }
}

function iframeOnLoad() {
    try {
        $("#ifMain").fadeIn(500);
        let CUrl = document.getElementById("ifMain").contentWindow.location.href;
        if (CUrl !== "about:blank" && CUrl.length > 22) {//22 => 避免儲存不是iFrame的網頁
            //Save Last Surf Url
            SaveLastGoUrl(CUrl);
            //GoPageHandler
            GoPageHandler(CUrl);//讀取後要放 因為返回功能不會經過 iframeHref
            RunGoPageHandler = true;
            //NaviStatusHandler
            NaviStatusHandler(CUrl);
            //App
            CallAppFunc("sProgressC");
        }
    } catch (e) {//通常是上線轉離線導致，這種行為會連帶Cache壞掉，發生方式 => 有網狀態登入 => 突然斷網 => 切換頁面
        SAlert("跳轉頁面發生錯誤", e.stack);
    }
}

async function SaveLastGoUrl(Url) {
    await SetCookie("SPLastGoUrl", Url);
    await SetCookie("SPLastGoUrlTime", new Date().getTime());
}

function GoPage(page, query = "") {
    let GoUrl = '/app/html/' + page + '.html';
    if (query.length > 0) GoUrl += "?" + query;
    iframeHref(GoUrl).then();
}

function GoPageHandler(GoUrl) {
    if (RunGoPageHandler) {
        let GoPage = GoUrl.substring(GoUrl.indexOf("html/") + 5, GoUrl.lastIndexOf(".html") + 5);//即將前往 或 已抵達的網址
        let ParseURL = new URL(window.location.href);
        let Params = ParseURL.searchParams;
        if (GoPage.length > 0) {
            Params.set("GoPage", GoPage);//設定GoPage
            history.replaceState(null, null, "?" + Params.toString());
        }
    }
}

function NaviStatusHandler(CUrl) {
    if (isPageLoaded) {
        //Image
        let imgPath = "/app/image/Page_Main/";
        GetEID("imgHome").src = imgPath + (CUrl.includes("Home") ? "ic_home_select.png" : "ic_home.png");
        GetEID("imgHistory").src = imgPath + (CUrl.includes("History") ? "ic_history_select.png" : "ic_history.png");
        GetEID("imgTrain").src = imgPath + (CUrl.includes("Train") ? "ic_train_select.png" : "ic_train.png");
        GetEID("imgMine").src = imgPath + (CUrl.includes("Mine") ? "ic_mine_select.png" : "ic_mine.png");
        //Text
        let pNavSelected = "pNavSelected";
        if (CUrl.includes("Home")) ClassAdder(GetEID("pHome"), pNavSelected);
        else ClassRemover(GetEID("pHome"), pNavSelected);
        if (CUrl.includes("History")) ClassAdder(GetEID("pHistory"), pNavSelected);
        else ClassRemover(GetEID("pHistory"), pNavSelected);
        if (CUrl.includes("Train")) ClassAdder(GetEID("pTrain"), pNavSelected);
        else ClassRemover(GetEID("pTrain"), pNavSelected);
        if (CUrl.includes("Mine")) ClassAdder(GetEID("pMine"), pNavSelected);
        else ClassRemover(GetEID("pMine"), pNavSelected);
    }
}

//Bluetooth=============================================================================================================
function JSFuncHandler(Func, Value) {
    if (Func === "BTMsgReceive") BTMsgReceive(Value);
}

function BTMsgReceive(Value) {
    if (ifMain != null) {
        let ifWin = ifMain.contentWindow;
        if (ifWin != null) {
            if (typeof ifWin.BTMsgReceive === "function") ifWin.BTMsgReceive(Value);
        }
        //Index handle
        BTMsgReceiveHandler(Value);
    }
}

function BTMsgReceiveHandler(Value) {
    let JOB = GetJOB(Value);
    let Cmd = JOBStrGet(JOB, "Cmd");
    let Res = JOBStrGet(JOB, "Res");
    let MsgJOB = JOBStrGetInit(JOB, "MsgJOB", {});
    if (Cmd === "Get_ShutdownAlert") {//準備關機提示
        Get_ShutdownAlert_MP();
    } else if (Cmd === "Get_RealTimeInfo") {
        Get_RealTimeInfo(Res, MsgJOB);
    }
}

function Get_ShutdownAlert_MP() {
    if (!Swal.isVisible()) {
        SAsk("裝置準備關機", "系統閒置已超過10分鐘", {
            Confirm: "保持開機",
            Cancel: "立即關機",
            ShowCancel: true
        }).then(result => {
            if (result.isConfirmed) {
                CallAppFunc("sendMsg", "Set_ShutdownAlert", "1");//保持開機
            } else {
                CallAppFunc("sendMsg", "Set_ShutdownAlert", "2");//立即關機
                CallAppFunc("disConnectDevice");//斷開連線
            }
        });
    }
}

let preCStatus = "";

function Get_RealTimeInfo(Res, MsgJOB) {
    if (Res === "1") {
        //Error Handler
        let Error = JOBStrGet(MsgJOB, "Error");
        if (Error.length > 0) {
            location.href = "/app/html/Page_Error.html";
        }
        //CStatus
        if (isApp()) {
            let CStatus = JOBNumGet(MsgJOB, "CStatus");
            if (CStatus !== preCStatus) {
                preCStatus = CStatus;
                if (CStatus === 10) {//Status_Process
                    CallAppFunc("sProgress", "設備運作中")
                } else {
                    CallAppFunc("sProgressC");
                }
            }
        }
    }
}

//Socket================================================================================================================
function InitSocketLogService() {
    SVOpenWebSocketServer().then(res => {
        if (res) {
            SVSetReceiveDataHandler(function (Data) {
                // console.log(Data);
                // let ResJOB = JSON.parse(Data);
                // let ApiName = JOBStrGet(ResJOB, "ApiName");
                // if (ApiName === "Set_Log") {
                //     //PLog(JOBStrGet(ResJOB, "ResMsg"))
                // }
            });
            //自動連接
            SVConnectSocketServer(SVWebSocketServerAddress).then(() => {
                if (SVSoc != null && SVSoc.readyState === 1) {//正常可以連接時
                    //每30秒 Ping 一次 防止被斷線
                    setInterval(function () {
                        SVSendData("Ping");
                    }, 30000);
                    //設定讀取console
                    // console.defaultLog = console.log.bind(console);
                    // console.log = async function () {
                    //     // default &  console.log()
                    //     console.defaultLog.apply(console, arguments);
                    //     // new & array data
                    //     SVSendMsg("Set_Log", JSON.stringify(Array.from(arguments)));
                    // }
                    console.log("BackgroundServiceListener Started");
                }
            }).catch(err => {
                Log("[error] " + err.message);
            });
        }
    }).catch(e => {
        SAlert("開啟SVSocketServer發生錯誤", e);
    });
}

//Device Connection=====================================================================================================
let preConnected = false;

async function DeviceConnectionChecker() {
    let connected = await isDeviceConnected();
    if (connected !== preConnected) {
        preConnected = connected;
        if (!connected) {
            let CUrl = GetEID("ifMain").src;
            if (!CUrl.includes("Home")) {
                SAlert("裝置已斷線");
                GoPage("Page_Home");
            }
        }
    }
    setTimeout(() => {
        DeviceConnectionChecker();
    }, 2000);
}