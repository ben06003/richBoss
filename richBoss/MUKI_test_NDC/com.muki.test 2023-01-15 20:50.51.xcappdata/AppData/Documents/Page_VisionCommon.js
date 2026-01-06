let CTrainInfoJOB = {};//目前訓練的內容

function Init() {
    //第一次詢問
    CallAppFunc("sendMsg", "Get_RealTimeInfo");
}

//Train=================================================================================================================
function StartTrain(tMode) {
    Get_TrainModel(tMode, InfoJOB => {
        //Read
        let TMode = JOBStrGet(InfoJOB, "TMode");
        let Times = InfoJOB["Times"];
        let ModeJA = JSON.parse(InfoJOB["ModeJA"]);
        //Check
        if (ModeJA == null || ModeJA.length === 0) {
            SAlert("沒有指令資料");
            return;
        } else if (ModeJA.length > 50) {
            SAlert("指令超過大小限制");
            return;
        } else if (Times == null) {
            SAlert("偵測到遺失 Times");
            return;
        }
        //Save
        CTrainInfoJOB = InfoJOB;
        //Convert
        let ConvertModeJA = ConvertToDegreeJA(ModeJA);//稜鏡度換算為角度
        //Prepare
        let JOB = {
            Mode: TMode,
            Repeat: Times,
            ModeJA: ConvertModeJA
        }
        // console.log(JOB)
        CallAppFunc("sendMsg", "Set_StartTrainMode", JSON.stringify(JOB));
    });
}

function StopTrain() {
    let JOB = {
        Mode: "Stop"
    }
    CallAppFunc("sendMsg", "Set_StartTrainMode", JSON.stringify(JOB));
}

function ConvertToDegreeJA(ModeJA) {
    //Convert
    let ConvertModeJA = [];//稜鏡度換算為角度
    for (let cnt = 0; cnt < ModeJA.length; cnt++) {
        let Mode = ModeJA[cnt];
        let Arrive = Mode[0];
        let Prism = Mode[1];
        let Stay = Mode[2];
        let Direction = Prism >= 0 ? 1 : -1;
        let Degree = Direction * ConvertToDegree(Math.abs(Prism));
        ConvertModeJA.push([Arrive, Degree, Stay])
    }
    return ConvertModeJA;
}

//Network===============================================================================================================
function Get_TrainModel(tMode, callback) {
    //Prepare
    let SendJOB = {
        tMode: tMode
    };
    SFetchClient(function (ResJOB) {
        let ResCode = JOBStrGet(ResJOB, "ResCode");
        let ResMsg = JOBStrGet(ResJOB, "ResMsg");
        if (ResCode === "1" || ResCode === "3") {//Login Success || Register Success
            let InfoJOB = ResJOB["InfoJOB"];
            if (typeof callback === "function") callback(InfoJOB);
        } else if (ResCode === "2") {
            SAlert("查無此訓練模型", tMode + " 請工程人員在後台佈署");
        } else {
            SAlert("未知的回應", "ResCode:" + ResCode + " ResMsg:" + ResMsg);
        }
    }, "Get_TrainModel", SendJOB);
}

//Bluetooth=============================================================================================================
function BTMsgReceive(Value) {
    let JOB = GetJOB(Value);
    let Cmd = JOBStrGet(JOB, "Cmd");
    let Res = JOBStrGet(JOB, "Res");
    let MsgJOB = JOBStrGetInit(JOB, "MsgJOB", {});
    if (Cmd === "Get_RealTimeInfo") {
        //BTMsgReceiveEx
        if (typeof Get_RealTimeInfoEx === "function") Get_RealTimeInfoEx(Res, MsgJOB);
    } else if (Cmd === "Set_StartTrainMode") {
        Set_StartTrainMode(Res);
        //Set_StartTrainModeEx
        if (typeof Set_StartTrainModeEx === "function") Set_StartTrainModeEx(Res);
    }
}

function Set_StartTrainMode(Res) {
    if (Res === "3") SAlert("解析失敗");
    else if (Res === "4") SAlert("指令超過裝置大小限制");
}