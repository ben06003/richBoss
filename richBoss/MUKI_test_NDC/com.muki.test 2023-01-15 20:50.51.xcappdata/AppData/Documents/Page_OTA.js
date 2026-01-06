let CurrentDeviceStatus = 0;
let deviceInfoJOB, deviceVerInfoJOB, updateType;
let fileFirmwareAry, fileFirmwareSize;
const targetFlashBytesPerTime = 35;//57 偶爾會失敗

window.onload = function () {
    //Param
    let ParseURL = new URL(window.location.href);
    let Params = ParseURL.searchParams;
    let sendJOB = JSON.parse(decodeURI(GetParam(Params, "sendJOB")));
    deviceInfoJOB = sendJOB["deviceInfoJOB"];
    deviceVerInfoJOB = sendJOB["deviceVerInfoJOB"];
    updateType = sendJOB["updateType"];
    console.log(sendJOB);
    StartFirmwareUpdate().then();
}

//Run===================================================================================================================

async function StartFirmwareUpdate() {
    try {
        UpdateState(10, "正在檢查環境");
        //Check bluetooth connection
        let connected = await isDeviceConnected();
        if (!connected) {
            UpdateState(0, "藍芽已斷開");
            return;
        }
        //check network
        if (!isNetAvailable()) {
            UpdateState(0, "尚未連接網路");
            return;
        }
        //check macAddress
        let macAddress = await GetCookie("macAddress");
        if (macAddress == null || macAddress.length === 0) {
            UpdateState(0, "缺少裝置 macAddress 資訊");
            return;
        }
        //check server & updateUrl
        let updateUrl;
        if (updateType === "official") updateUrl = JOBStrGet(deviceVerInfoJOB, "UpdateUrl");
        else updateUrl = JOBStrGet(deviceVerInfoJOB, "BetaUpdateUrl");
        if (!isServerAvailable(updateUrl)) {
            UpdateState(0, "無法連接到檔案伺服器");
            return;
        }

        //Download Firmware
        let filename = "firmware.bin";
        UpdateState(15, "正在下載韌體");
        let result = await fileDownloader(updateUrl, filename);
        if (result === null) {
            UpdateState(0, "下載韌體失敗");
            return;
        }

        //Start Flash Firmware
        UpdateState(20, "準備寫入檔案");
        fileFirmwareAry = base64ToByteArray(localStorage.getItem(filename));
        if (fileFirmwareAry === null) {
            UpdateState(0, "讀取裝置韌體失敗");
            return;
        }
        fileFirmwareSize = fileFirmwareAry.byteLength;

        UpdateState(25, "裝置準備寫入");
        //告知裝置開始準備OTA
        let OTAInfoJOB = {
            Cmd: "1",
            FileSize: fileFirmwareSize
        }
        CallAppFunc("sendMsg", "Set_FWUpdate", JSON.stringify(OTAInfoJOB));

        //等待裝置更新 BLE版本 超時設為15分鐘
        let startM = GetCurrentM();
        while (CurrentDeviceStatus !== 6) {//判斷韌體是否寫入完成
            if (GetCurrentM() - startM > (15 * 60000)) {
                UpdateState(0, "更新超時");
                return;
            }
            await delay(100);
        }

        UpdateState(90, "韌體寫入完成\n等待裝置重啟");//開機完成
        //等裝置斷線 (等裝置重開機)
        startM = GetCurrentM();
        while (await isDeviceConnected()) {
            if (GetCurrentM() - startM > 30000) {
                UpdateState(0, "等待裝置斷線超時");
                return;
            }
            await delay(100);
        }

        //自動重連裝置
        await delay(1000)
        CallAppFunc("connectDevice", macAddress);

        //等待裝置連線
        let preConnectM = GetCurrentM();
        startM = GetCurrentM();
        while (!await isDeviceConnected()) {
            //檢查超時
            if (GetCurrentM() - startM > 60000) {
                UpdateState(0, "等待連接裝置超時");
                return;
            }
            //自動嘗試重連
            if (GetCurrentM() - preConnectM > 20000) {
                CallAppFunc("connectDevice", macAddress);
                preConnectM = GetCurrentM();
            }
            await delay(100);
        }

        //裝置連接成功 前往準備頁
        UpdateState(100, "裝置更新完成\n即將跳轉");//開機完成
        setTimeout(function () {
            top.location.href = "/app/html/Page_Prepare.html";
        }, 2000);
    } catch (e) {
        UpdateState(0, "升級過程發生錯誤", e.toString());
    }
}

//View==================================================================================================================
let preProgress = 0;

function UpdateState(progress, status, hint = "") {
    //Progress
    if (progress === 0 || progress === 100) {
        ClassRemover(GetEID("btFunc"), "invisible");
        ClassAdder(GetEID("lpLoading"), "hidden");
    }
    GetEID("pStatus").innerText = status;
    //CircleProgress 必須要顯示後才能使用
    GetEID("stProgress").innerHTML = progress + '<i>%</i>';
    let cProgress = progress / 100;
    $(GetEID("divProgress")).circleProgress({
        startAngle: -1.57,//Max 3.14
        animation: {
            duration: 500, easing: "circleProgressEasing"
        },
        animationStartValue: preProgress,
        value: cProgress,
        size: 300,
        constrain: true,
        textFormat: 'percent',
        fill: {
            gradient: ["orange", "red"]
        }
    });
    preProgress = cProgress;
    //Hint
    GetEID("pHint").innerText = hint;
}

//Bluetooth=============================================================================================================
function JSFuncHandler(Func, Value) {
    if (Func === "BTMsgReceive") {
        BTMsgReceiveHandler(Value);
    }
}

function BTMsgReceiveHandler(Value) {
    let JOB = GetJOB(Value);
    let Cmd = JOBStrGet(JOB, "Cmd");
    let Res = JOBStrGet(JOB, "Res");
    if (Cmd === "Set_FWUpdate") {
        Set_FWUpdate(Res, JOB);
    } else if (Cmd === "OTA") {
        Set_OTABlue(Res, JOB);
    }
}

function Set_FWUpdate(Res, JOB) {
    try {
        //Update Status
        switch (Res) {
            case "1":
                UpdateState(0, "電量低於10%，請先充電");
                break;
            case "2":
                UpdateState(0, "升級時必須將裝置插入電源");
                break;
            case "3":
                UpdateState(30, "裝置開始更新");
                break;
            case "4":
                UpdateState(0, "裝置初始化更新失敗\n請稍後重新嘗試");
                break;
            case "5":
                UpdateState(0, "刷入韌體失敗\n請稍後重新嘗試");
                break;
            case "6":
                UpdateState(80, "韌體寫入完成\n請稍待裝置重啟");
                break;
            case "7":
                UpdateState(0, "裝置更新失敗\n請稍後重新嘗試");
                break;
            case "8":
                UpdateState(0, "裝置更新意外中斷\n請稍後重新嘗試");
                break;
            case "10"://Progress
                let ProgressJOB = JOB["MsgJOB"];
                let Progress = 30 + parseFloat(JOBStrGet(ProgressJOB, "PGS"));
                let EstSec = JOBNumGet(ProgressJOB, "EST");
                let Min = (EstSec / 60).toFixed(0);
                let Sec = EstSec % 60;
                UpdateState(Progress, "裝置更新中\n剩餘時間: " + Min + "分" + Sec + "秒");
                console.log(ProgressJOB)
                break;
            case "11":
                UpdateState(0, "裝置偵測到更新超時\n請稍後重新嘗試");//開機完成
                break;
            case "13":
                UpdateState(0, "裝置解析訊息失敗");
                break;
            default:
                UpdateState(0, "未知狀態");
                break;
        }
        CurrentDeviceStatus = parseInt(Res);//必須在 switch 之後
    } catch (e) {
        SAlert("Set_FWUpdate發生錯誤", e.toString());
    }
}

function Set_OTABlue(Res, JOB) {
    if (Res === "2") {
        try {
            //OTAInfoJOB
            let OTAInfoJOB = {};
            //Read State
            let OTAStateJOB = JOB["MsgJOB"];
            let startPos = JOBNumGet(OTAStateJOB, "NSP");
            //File
            if (startPos < fileFirmwareSize) {
                //Get targetSendBytePerTime
                let NodeVersion = JOBNumGet(deviceInfoJOB, "NodeVersion");
                let targetSendBytePerTime = 512;
                if (NodeVersion >= 38) targetSendBytePerTime = 4096;//版本38之後加大Buffer至 8192
                //DataJA
                let DataJA = [];
                let estReadTimes = Math.round(targetSendBytePerTime / targetFlashBytesPerTime);
                let remainByte = targetSendBytePerTime % targetFlashBytesPerTime;//無法取整數時 剩下的Byte
                for (let cnt = 0; cnt < estReadTimes; cnt++) {
                    if (startPos < fileFirmwareSize) {
                        startPos = ReadFirmwareFile(startPos, fileFirmwareSize, targetFlashBytesPerTime, DataJA);
                    } else {
                        break;
                    }
                }
                //Remain part
                if (startPos < fileFirmwareSize) {
                    startPos = ReadFirmwareFile(startPos, fileFirmwareSize, remainByte, DataJA);
                }
                //Send
                OTAInfoJOB["PGS"] = "2";//Flash data
                OTAInfoJOB["DJA"] = DataJA;
                OTAInfoJOB["NSP"] = startPos;
            } else {
                OTAInfoJOB["PGS"] = "3";//Flash end
            }
            //Basic info
            OTAInfoJOB["Cmd"] = "OTA";
            //Send
            CallAppFunc("sendMsgJOB", JSON.stringify(OTAInfoJOB));
        } catch (e) {
            UpdateState(0, "更新發生錯誤\n" + e.toString());
        }
    }
}

function ReadFirmwareFile(startPos, fileSize, flashBytesPerTime, DataJA) {
    if (startPos < fileSize) {
        //Check Remain
        let RemainSize = fileSize - startPos;
        if (RemainSize < flashBytesPerTime) {
            flashBytesPerTime = RemainSize;
        }

        let endPos = startPos + flashBytesPerTime;
        let bytesAry = fileFirmwareAry.slice(startPos, endPos);
        //Read Data
        let resultBase64 = byteArrayToBase64(bytesAry);
        DataJA.push(resultBase64);
        //Add StartPos
        startPos += flashBytesPerTime;
    }
    return startPos;
}