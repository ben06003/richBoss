let updateTypeTmp = "";

window.onload = async function () {
    //View
    top.SetHeaderInfo("系統資訊", () => {
        top.GoPage("Page_Mine");
    })
    //顯示模式
    await ViewHandler();
    //裝置資訊
    if (await isDeviceConnected()) CallAppFunc("sendMsg", "Get_DeviceSettings");
    else Get_DeviceSettings("offline", {}).then();
}

async function ViewHandler() {
    let ELs = document.getElementsByClassName("develop");
    let Develop = await GetCookie("Develop") === "T";
    for (let cnt = 0; cnt < ELs.length; cnt++) {
        let element = ELs[cnt];
        if (Develop) ClassRemover(element, "hidden");
        else ClassAdder(element, "hidden");
    }
}

async function ExperimentHandler(El) {
    let Experiment = El.checked;
    if (Experiment) {
        Swal.fire({
            title: '請輸入密碼',
            input: 'text',
            inputAttributes: {
                autocapitalize: 'off'
            },
            showCancelButton: true,
            confirmButtonText: '確認',
            cancelButtonText: '取消',
            preConfirm: (password) => {
                //Check password
                if (password === "abcd1234") {
                    return true;
                } else {
                    SAlert("密碼錯誤");
                    El.checked = !El.checked;//Auto restore
                    return false;
                }
            }
        }).then(async (result) => {
            if (result.isConfirmed) {
                if (result.value) {
                    await SetCookie("Experiment", "T");
                    top.IndexViewHandler().then();
                    SAlert("已開啟實驗模式");
                }
            } else {//Cancel
                El.checked = !El.checked;//Auto restore
            }
        })
    } else {
        await SetCookie("Experiment", "F");
        top.IndexViewHandler().then();
    }
}

async function DevelopHandler(El) {
    let Develop = El.checked;
    if (Develop) {
        Swal.fire({
            title: '請輸入密碼',
            input: 'text',
            inputAttributes: {
                autocapitalize: 'off'
            },
            showCancelButton: true,
            confirmButtonText: '確認',
            cancelButtonText: '取消',
            preConfirm: (password) => {
                //Check password
                if (password === "abcd12345678") {
                    return true;
                } else {
                    SAlert("密碼錯誤");
                    El.checked = !El.checked;//Auto restore
                    return false;
                }
            }
        }).then(async (result) => {
            if (result.isConfirmed) {
                if (result.value) {
                    await SetCookie("Develop", "T");
                    top.IndexViewHandler().then();
                    ViewHandler().then();
                    SAlert("已開啟工程模式");
                }
            } else {//Cancel
                El.checked = !El.checked;//Auto restore
            }
        })
    } else {
        await SetCookie("Develop", "F");
        await top.IndexViewHandler();
        await ViewHandler();
    }
}

function CanUseCacheHandler(El) {
    SetCookie("canUseCache", El.checked ? "T" : "F").then();
}

function UpdateNode(updateType) {
    if (isNetAvailable()) {
        updateTypeTmp = updateType;
        SAsk("確認要強制更新裝置?", "更新過程中請接上電源").then(function (result) {
            if (result.isConfirmed) {
                CallAppFunc("sendMsg", "Get_AvailableUpdate");
            }
        })
    } else SAlert("請先連接網絡");
}

function UpdateApp(updateType) {
    if (isNetAvailable()) {
        CallAppFunc("updateApp", updateType);
    } else SAlert("請先連接網絡");
}

function RebootNode() {
    SAsk("確認要重啟裝置?", "您將會需要重新連接裝置").then(function (result) {
        if (result.isConfirmed) {
            if (isApp()) {
                CallAppFunc("sendMsg", "Set_RebootDevice", "1");
                CallAppFunc("disConnectDevice");
            }
        }
    })
}

function CheckRGBLight() {
    if (isApp()) {
        CallAppFunc("sendMsg", "Set_CheckRGBLight");
        SAlert("已送出指令");
    }
}

function UpdateWBVCache() {
    if (isApp()) {
        SAlert("已呼叫更新快取");
        CallAppFunc("setUpdateWBVCache");
    }
}

//Bluetooth=============================================================================================================
function BTMsgReceive(Value) {
    let JOB = GetJOB(Value);
    let Cmd = JOBStrGet(JOB, "Cmd");
    let Res = JOBStrGet(JOB, "Res");
    let MsgJOB = JOBStrGetInit(JOB, "MsgJOB", {});
    if (Cmd === "Get_DeviceSettings") {
        Get_DeviceSettings(Res, MsgJOB).then();
    } else if (Cmd === "Get_AvailableUpdate") {
        Get_AvailableUpdate(Res).then();
    }
}

async function Get_DeviceSettings(Res, MsgJOB) {
    if (Res === "1") {
        //DeviceType
        let DeviceType = JOBNumGet(MsgJOB, "DeviceType");
        if (DeviceType === 0) DeviceType = "行動版";
        else if (DeviceType === 1) DeviceType = "桌面版";
        else DeviceType = "未知類型";
        //Show
        GetEID("pDeviceType").innerText = DeviceType;
        GetEID("pNodeVer").innerText = JOBStrGet(MsgJOB, "NodeVersion");
        GetEID("inSLG").checked = JOBNumGet(MsgJOB, "SLG") === 1;
        GetEID("pDeviceId").innerText = JOBStrGet(MsgJOB, "DeviceId");
    } else if (Res === "offline") {
        let msg = "裝置未連接";
        GetEID("pDeviceType").innerText = msg;
        GetEID("pNodeVer").innerText = msg;
        GetEID("inSLG").checked = false;
        GetEID("pDeviceId").innerText = msg;
    }
    //Show
    GetEID("inExperiment").checked = await GetCookie("Experiment") === "T";
    GetEID("inDevelop").checked = await GetCookie("Develop") === "T";
    GetEID("inCanUseCache").checked = await GetCookie("canUseCache") !== "F";
    //AppInfo
    let appInfo = await CallAppFuncCB("getAppInfo");
    let ResJOB = JSON.parse(appInfo.toString());
    GetEID("pAppVer").innerText = JOBStrGet(ResJOB, "AppVersion");
    //套件資訊
    let haveCache = await CallAppFuncCB("getSPValue", "haveCache");
    GetEID("pHaveCache").innerText = haveCache === "T" ? "已同步" : "無資料";
}

function Set_DeviceSettings() {
    if (isApp()) {
        //Send
        let JOB = {
            SLG: GetEID("inSLG").checked ? 1 : 0
        }
        CallAppFunc("sendMsg", "Set_DeviceSettings", JSON.stringify(JOB));
    }
}

async function Get_AvailableUpdate(Res) {
    if (Res === "1") {
        if (updateTypeTmp.length > 0) {
            if (isApp()) {
                let sendJOB = {
                    updateType: updateTypeTmp,
                    deviceInfoJOB: await GetStorage("deviceInfoJOB"),
                    deviceVerInfoJOB: await GetStorage("deviceVerInfoJOB")
                }
                top.location.href = "/app/html/Page_OTA.html?sendJOB=" + encodeURI(JSON.stringify(sendJOB));
            }
        } else {
            SAlert("偵測到遺失資訊", "updateTypeTmp%");
        }
    } else if (Res === "2") {
        SAlert("電量太低", "最低電量必須為10%");
    } else if (Res === "3") {
        SAlert("未充電", "請連接電源線後進行升級");
    }
}
