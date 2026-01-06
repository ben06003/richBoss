//View
let divTrainHisItemTmp;

window.onload = function () {
    //View
    divTrainHisItemTmp = GetEID("divTrainHisItem");
    CallAppFunc("setOrientation", "portrait");//設為直立模式
    top.SetHeaderInfo("");//Hide
    top.SetFooterShow(true);//Show
    //Data
    ShowPageInfo().then();
    Get_MonthHistory();
    DeviceStatusHandler(true).then();
}

//View==================================================================================================================
async function ShowPageInfo() {
    GetEID("pName").innerText = await GetCookie("name");
    //Photo
    let Photo = await GetCookie("photo");
    if (Photo.length > 0) GetEID("imgHead").src = Photo;
}

async function DeviceStatusHandler(callUpdate) {
    //Device Name
    if (await isDeviceConnected()) {
        //DeviceName
        let showDeviceName = "";
        let deviceInfoJOB = await GetStorage("deviceInfoJOB");
        let deviceName = JOBStrGet(deviceInfoJOB, "DeviceName");
        if (deviceName.includes("VT_M")) showDeviceName = "訓練儀 - " + deviceName.replace("VT_M_", "");
        GetEID("pDeviceName").innerText = showDeviceName;
        //Battery
        ClassRemover(GetEID("divBattery"), "invisible");
        //Connect Button
        GetEID("btDeviceConnection").innerText = "中斷";
    } else {//未連線
        //DeviceName
        GetEID("pDeviceName").innerText = "裝置尚未連接";
        //Battery
        ClassAdder(GetEID("divBattery"), "invisible");
        //Connect Button
        GetEID("btDeviceConnection").innerText = "連接";
    }
    if (callUpdate) {
        setTimeout(function () {
            DeviceStatusHandler(true);
        }, 2500)
    }
}

async function ConnectDeviceButton() {
    if (await isDeviceConnected()) {
        CallAppFunc("disConnectDevice");//斷開裝置
        setTimeout(function () {
            DeviceStatusHandler(false).then();//快速更新裝置連接狀態
        }, 500);
    } else {
        top.location.href = "/app/html/Page_Connect.html?From=Home";//前往連接裝置
    }
}

//Bluetooth=============================================================================================================
function BTMsgReceive(Value) {
    let JOB = GetJOB(Value);
    let Cmd = JOBStrGet(JOB, "Cmd");
    let Res = JOBStrGet(JOB, "Res");
    let MsgJOB = JOBStrGetInit(JOB, "MsgJOB", {});
    if (Cmd === "Get_RealTimeInfo") {
        Get_RealTimeInfo(Res, MsgJOB);
    }
}

function Get_RealTimeInfo(Res, MsgJOB) {
    if (Res === "1") {
        //Battery
        let Battery = JOBStrGet(MsgJOB, "Battery");
        GetEID("pBatteryPercent").innerText = Battery + (Battery >= 100 ? "" : "%");
        //Battery Draw
        let divBatteryPercent = GetEID("divBatteryPercent");
        divBatteryPercent.style.width = Battery + "%";
        if (Battery > 15) {
            ClassRemover(divBatteryPercent, "bg-red-400");
            ClassAdder(divBatteryPercent, "bg-green-400");
        } else {
            ClassRemover(divBatteryPercent, "bg-green-400");
            ClassAdder(divBatteryPercent, "bg-red-400");
        }
        //Charging
        let ChargingNow = JOBStrGet(MsgJOB, "ChargingNow");
        if (ChargingNow === true) {
            ClassRemover(GetEID("divCharge"), "hidden");
        } else {
            ClassAdder(GetEID("divCharge"), "hidden");
        }
        //Voltage
        GetEID("pVoltage").innerText = JOBNumGet(MsgJOB, "Voltage").toFixed(2) + "V";
    }
}

function ShowHistoryInfo(InfoJOB) {
    let TrainHisJA = InfoJOB["TrainHisJA"];
    //TrainHis List
    let divTrainHisList = GetEID("divTrainHisList");
    divTrainHisList.innerHTML = null;
    for (let cnt = 0; cnt < TrainHisJA.length; cnt++) {
        let JOB = TrainHisJA[cnt];
        let divTrainHisItem = CloneEl(divTrainHisItemTmp);
        GetEID("pETime", divTrainHisItem).innerText = GetDateTime(JOBStrGet(JOB, "ETime"));
        GetEID("pMName", divTrainHisItem).innerText = JOBStrGet(JOB, "MName");
        GetEID("pTTime", divTrainHisItem).innerText = JOBNumGet(JOB, "TTime") + " 秒";
        GetEID("pFinish", divTrainHisItem).innerText = JOBStrGet(JOB, "Finish") === "T" ? "完成" : "中斷";
        divTrainHisList.appendChild(divTrainHisItem);
    }
    $(divTrainHisList).fadeIn(500);
    //CheckHis
    let pScore = GetEID("pScore");
    let CheckHisJA = InfoJOB["CheckHisJA"];
    if (CheckHisJA.length > 0) {
        let JOB = CheckHisJA[0];
        pScore.innerText = JOBStrGet(JOB, "Score");
    } else {
        pScore.innerText = "0";
    }
    ClassRemover(pScore, "invisible")
    $(pScore).fadeIn(500);
}

//Network===============================================================================================================
function Get_MonthHistory() {
    //Read
    let date = new Date(Date.now());
    //Prepare
    let SendJOB = {
        year: date.getFullYear(),
        month: (date.getMonth() + 1),
        mode: "recent"
    };
    SFetchClient(function (ResJOB) {
        let ResCode = JOBStrGet(ResJOB, "ResCode");
        let ResMsg = JOBStrGet(ResJOB, "ResMsg");
        if (ResCode === "1") {//Success
            ShowHistoryInfo(ResJOB["InfoJOB"]);
        } else {
            SAlert("未知的回應", "ResCode:" + ResCode + " ResMsg:" + ResMsg);
        }
    }, "Get_MonthHistory", SendJOB);
}