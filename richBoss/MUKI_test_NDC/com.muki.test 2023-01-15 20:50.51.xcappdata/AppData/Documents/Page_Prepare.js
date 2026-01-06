let StartM;
let TOId_Resend, TOId_Connect;
const DeviceKey = "7acf2730-8b31-4b9c-b959-3fd8023b48f3";
const MainPageUrl = "/app/html/Page_Main.html";
const MinStayM = 1500;

window.onload = function () {
    // new VConsole();
    StartM = GetCurrentM();
    if (isApp()) CheckVersionInfo();//檢查版本資訊
    //偵測到比較長時間沒回應，直接重問裝置資訊
    TOId_Resend = setTimeout(function () {
        CallAppFunc("sendMsg", "Get_DeviceInfo");//取得裝置版本資訊
    }, 6000);
    //Detect timeout
    TOId_Connect = setTimeout(function () {
        SAsk("偵測到準備時間超時", "即將返回連接頁", {
            Confirm: "立即返回",
            ShowCancel: false,
            CancelAble: false
        }).then(result => {
            if (result.isConfirmed) LogoutToConnect(false);
        });
    }, 15000);
}

window.onerror = function (msg, url, line, col, error) {
    let errorMsg = "發生運行錯誤:";
    errorMsg += "\nmsg:" + msg;
    errorMsg += "\nline:" + line;
    errorMsg += "\ncol:" + col;
    errorMsg += "\nerror:" + error;
    UpdateStatus(errorMsg, false);
    //set anim stop
    let lpLoading = GetEID("lpLoading");
    lpLoading.stop();
    lpLoading.seek(12);
}

//View==================================================================================================================
function UpdateStatus(status, loading = true) {
    GetEID("pStatus").innerText = status;
    if (!loading) {
        ClassAdder(GetEID("lpLoading"), "invisible");
        ClassRemover(GetEID("btFunc"), "hidden");
    }
}

//Network===============================================================================================================
let deviceVerInfoJOB = null;

function CheckVersionInfo() {
    //Prepare
    let SendJOB = {
        PackageName: "com.vegtek.glasscontrol.esp32"
    };
    if (isNetAvailable()) {//網絡允許時，才去問API
        //Fade pointer-events
        UpdateStatus("正在從伺服器取得裝置版本資訊");
        SFetchClient(async function (ResJOB) {
            if (ResJOB != null) {
                if (isApp()) {
                    //儲存裝置版本資訊
                    deviceVerInfoJOB = ResJOB;
                    await SetStorage("deviceVerInfoJOB", deviceVerInfoJOB);
                    //登入裝置
                    UpdateStatus("正在登入裝置");
                    CallAppFunc("sendMsg", "Get_Login", DeviceKey);
                } else {
                    UpdateStatus("環境資訊錯誤", false);
                }
            } else {
                SAlert("未接收到資料");
            }
        }, "", SendJOB, {
            ApiUrl: "api_version.php"
        });
    } else {//無網絡時直接登入裝置
        UpdateStatus("正在登入裝置");
        CallAppFunc("sendMsg", "Get_Login", DeviceKey);
    }
}

function Get_DeviceUniqueId(deviceInfoJOB) {
    getLocation(function (position) {
        //Loc
        let latitude = 0;
        let longitude = 0;
        if (position != null) {
            latitude = position.coords.latitude;
            longitude = position.coords.longitude;
        }
        //Device
        let deviceType = JOBStrGet(deviceInfoJOB, "DeviceType");
        let macAddress = JOBStrGet(deviceInfoJOB, "MacAddress");
        let deviceId = JOBStrGet(deviceInfoJOB, "DeviceId");
        let firmware = JOBStrGet(deviceInfoJOB, "NodeVersion");
        //Prepare
        let SendJOB = {
            deviceId: deviceId.toString(),
            deviceType: deviceType.toString(),
            firmware: firmware.toString(),
            macAddress: macAddress,
            latitude: latitude.toString(),
            longitude: longitude.toString(),
        };
        console.log(JSON.stringify(SendJOB));
        if (isNetAvailable()) {//網絡允許時，才去問API
            //Fade pointer-events
            UpdateStatus("正在確認裝置ID");
            SFetchClient(async function (ResJOB) {
                if (ResJOB != null) {
                    let ResCode = JOBStrGet(ResJOB, "ResCode");
                    let ResMsg = JOBStrGet(ResJOB, "ResMsg");
                    if (ResCode === "1") {//裝置ID相同 通過檢查 可略過同步ID
                        SyncAppType();
                    } else if (ResCode === "2" || ResCode === "3") {//裝置ID不相同 需要更新裝置ID資訊 | 查無裝置 立即新增裝置
                        let InfoJOB = ResJOB["InfoJOB"];
                        let DID = JOBNumGet(InfoJOB, "DID");
                        if (DID > 0) SyncDeviceId(AFN(DID, 6));
                        else UpdateStatus("偵測到遺失 DID", false);
                    } else if (ResCode === "4") {//Failed
                        UpdateStatus("新增裝置ID失敗" + ResMsg, false);
                    } else {
                        SAlert("未知的回應", "ResCode:" + ResCode + " ResMsg:" + ResMsg);
                    }
                } else {
                    SAlert("未接收到資料");
                }
            }, "Get_DeviceUniqueId", SendJOB);
        } else {//無網絡時直接設定App類型
            SyncAppType();
        }
    })
}


//Bluetooth Receive=====================================================================================================
function JSFuncHandler(Func, Value) {
    if (Func === "BTMsgReceive") {
        BTMsgReceiveHandler(Value).then();
    }
}

async function BTMsgReceiveHandler(Value) {
    console.log("Value: " + Value);
    let JOB = GetJOB(Value);
    let Cmd = JOBStrGet(JOB, "Cmd");
    let Res = JOBStrGet(JOB, "Res");
    // let Msg = JOBStrGet(JOB, "Msg");
    let MsgJOB = JOBStrGetInit(JOB, "MsgJOB", {});
    if (Value.includes("Get_Login") && Cmd !== "Get_Login") {//相容舊版韌體
        Res = Value.includes("\"Res\":\"1\"") ? "1" : "2";
        MsgJOB["AuthToken"] = Value.substring(Value.indexOf("AuthToken\":\"") + 12, Value.indexOf("\"}\"}"));
        Get_Login(Res, MsgJOB).then();
    } else if (Cmd === "Get_Login") {//版本45以上適用
        Get_Login(Res, MsgJOB).then();
    } else if (Cmd === "Get_DeviceInfo") {
        Get_DeviceInfo(Res, MsgJOB).then();
    } else if (Cmd === "Set_DeviceUniqueId") {
        Set_DeviceUniqueId(Res);
    } else if (Cmd === "Set_AppType") {
        Set_AppType(Res);
    } else if (Cmd === "Set_EEPValue") {
        Set_EEPValue(Res);
    } else if (Cmd === "Get_AvailableUpdate") {
        Get_AvailableUpdate(Res).then();
    }
}

async function Get_Login(Res, MsgJOB) {
    if (Res === "1") {
        let AuthToken = JOBStrGet(MsgJOB, "AuthToken");
        await SetCookie("AuthToken", AuthToken);
        //取得裝置版本資訊
        UpdateStatus("正在取得裝置資訊");
        CallAppFunc("sendMsg", "Get_DeviceInfo");
    } else {
        SAlert("登入驗證失敗");
    }
}

async function Get_DeviceInfo(Res, MsgJOB) {
    if (Res !== "1") {
        UpdateStatus("取得裝置資訊發生錯誤", false);
        LogoutToConnect();
        return;
    }
    if (isApp()) {
        //Node最新資訊
        let isAuth = JOBStrGet(deviceVerInfoJOB, "isAuth");
        let version = JOBStrGet(deviceVerInfoJOB, "Version");
        //App版本資訊
        let appInfo = await CallAppFuncCB("getAppInfo");
        let appInfoJOB = JSON.parse(appInfo.toString());
        let appVersion = JOBNumGet(appInfoJOB, "AppVersion");
        //Node版本資訊
        let deviceInfoJOB = MsgJOB;
        let nodeVersion = JOBStrGet(deviceInfoJOB, "NodeVersion");
        let appRequireV = JOBStrGet(deviceInfoJOB, "AppRequireV");
        let deviceType = JOBStrGet(deviceInfoJOB, "DeviceType");
        await SetStorage("deviceInfoJOB", deviceInfoJOB);
        await SetCookie("deviceType", deviceType.toString());
        //開始檢查，有網絡環境時才檢查
        if (deviceVerInfoJOB != null) {
            if (!isAuth) {
                CancelTimeout();//取消超時偵測
                SAsk("裝置尚未授權", "即將中斷連接", {
                    Confirm: "確認",
                    ShowCancel: false,
                    CancelAble: false
                }).then(result => {
                    if (result.isConfirmed) {
                        LogoutToConnect(false);
                    }
                });
                return;
            }
            if (appVersion < appRequireV) {
                CancelTimeout();//取消超時偵測
                SAsk("App需要更新", "請立即更新後方能連接", {
                    Confirm: "立即更新",
                    Cancel: "返回首頁",
                    ShowCancel: true,
                    CancelAble: false
                }).then(result => {
                    if (result.isConfirmed) {
                        CallAppFunc("updateApp", "official");
                        CallAppFunc("logout");
                    } else {
                        LogoutToConnect(false);
                    }
                });
                return;
            }
            if (nodeVersion < version) {
                CancelTimeout();//取消超時偵測
                SAsk("裝置需要更新", "請立即更新後方能連接",
                    {
                        Confirm: "立即更新",
                        Cancel: "返回首頁",
                        ShowCancel: true,
                        CancelAble: false
                    }).then(result => {
                    if (result.isConfirmed) {
                        if (isApp()) {
                            UpdateStatus("正在確認是否可以更新");
                            CallAppFunc("sendMsg", "Get_AvailableUpdate");
                        }
                    } else {
                        LogoutToConnect(false);
                    }
                });
                return;
            }
        }
        //確認裝置唯一編號
        Get_DeviceUniqueId(deviceInfoJOB);
    } else SAlert("請使用App操作本系統");
}

function Set_AppType(Res) {
    if (Res === "1") {
        SyncDeviceSettings(); //同步最新設定資訊
    } else {
        let errMsg = "未知錯誤";
        if (Res === "2") errMsg = "傳入錯誤的類型";
        else if (Res === "3") errMsg = "解析訊息失敗";
        UpdateStatus("設定App類型失敗\n" + errMsg, false);
        LogoutToConnect();
    }
}

function Set_DeviceUniqueId(Res) {
    if (Res === "1") {
        SyncAppType();//設定目前連接的App系統
    } else {
        let errMsg = "未知錯誤";
        if (Res === "2") errMsg = "儲存DID失敗";
        else if (Res === "3") errMsg = "解析訊息失敗";
        UpdateStatus("設定裝置ID失敗\n" + errMsg, false);
        LogoutToConnect();
    }
}

function Set_EEPValue(Res) {
    if (Res === "1") {
        UpdateStatus("同步裝置設定成功");
        let GapM = GetCurrentM() - StartM;
        if (GapM < MinStayM) {
            setTimeout(function () {
                location.href = MainPageUrl;
            }, MinStayM - GapM);
        } else location.href = MainPageUrl;
    } else {
        UpdateStatus("同步裝置設定失敗", false);
        LogoutToConnect();
    }
}

async function Get_AvailableUpdate(Res) {
    if (Res === "1") {
        let sendJOB = {
            updateType: "official",
            deviceInfoJOB: await GetStorage("deviceInfoJOB"),
            deviceVerInfoJOB: await GetStorage("deviceVerInfoJOB")
        }
        location.href = "/app/html/Page_OTA.html?sendJOB=" + encodeURI(JSON.stringify(sendJOB));
    } else if (Res === "2") {
        UpdateStatus("電量太低\n最低電量必須為10%", false);
        SAlert("電量太低", "最低電量必須為10%");
    } else if (Res === "3") {
        UpdateStatus("未充電\n請連接電源線後進行升級", false);
        SAlert("未充電", "請連接電源線後進行升級");
    }
}

//Bluetooth Send========================================================================================================
//設定目前連接的App系統
function SyncAppType() {
    UpdateStatus("正在設定APP類型");
    //Send
    let AppType = "";
    if (isAndroid()) AppType = "Android";
    else if (isIOS()) AppType = "iOS";
    let JOB = {
        AppType: AppType
    }
    CallAppFunc("sendMsg", "Set_AppType", JSON.stringify(JOB));
}

//同步裝置與伺服器的ID
function SyncDeviceId(DID) {
    UpdateStatus("正在設定裝置ID");
    let JOB = {
        DeviceId: DID
    }
    CallAppFunc("sendMsg", "Set_DeviceUniqueId", JSON.stringify(JOB));
}


//SyncDeviceSettings
function SyncDeviceSettings() {
    UpdateStatus("正在同步裝置設定");
    let ValJA = [];
    ValJA.push({Pos: 3, Val: 5});//馬達功率Map 起始頻率 *10
    ValJA.push({Pos: 4, Val: 150});//馬達功率Map 結束頻率 *10
    ValJA.push({Pos: 8, Val: 70});//馬達最低功率
    ValJA.push({Pos: 43, Val: 115});//VoltageRange_H 電壓讀取Map，實際值要 +600
    //Send
    let JOB = {
        ValJA: ValJA
    }
    CallAppFunc("sendMsg", "Set_EEPValue", JSON.stringify(JOB));
}

//Common
function LogoutToConnect(delay = true) {
    setTimeout(function () {
        CallAppFunc("disConnectDevice");//斷開連線
        location.href = "/app/html/Page_Connect.html";
    }, delay ? MinStayM : 0);
}

function ForceUpdate() {
    CallAppFunc("sendMsg", "Get_AvailableUpdate");
}

function CancelTimeout() {
    clearTimeout(TOId_Resend);
    clearTimeout(TOId_Connect);
}
