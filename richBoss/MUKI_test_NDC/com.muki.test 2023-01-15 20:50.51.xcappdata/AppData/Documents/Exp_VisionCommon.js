let isTraining = false;

function Init() {
    //第一次詢問
    CallAppFunc("sendMsg", "Get_RealTimeInfo");
}

function StartTrain() {
    let Type = GetEID("slType").value;
    let Mode = GetEID("slMode").value;
    let Repeat = 0;//重複次數
    let ModeJA = [];
    //Read
    if (Type === "1") {//內聚不足視力訓練
        switch (Mode) {
            case "Mode1_A1":
                Repeat = 60;
                ModeJA = Mode1_A1;
                break;
            case "Mode1_A2":
                Repeat = 54;
                ModeJA = Mode1_A2;
                break;
            case "Mode1_A3":
                Repeat = 48;
                ModeJA = Mode1_A3;
                break;
            case "Mode1_A4":
                Repeat = 44;
                ModeJA = Mode1_A4;
                break;
            case "Mode1_A5":
                Repeat = 40;
                ModeJA = Mode1_A5;
                break;
            case "Mode1_A6":
                Repeat = 36;
                ModeJA = Mode1_A6;
                break;
            case "Mode1_A7":
                Repeat = 33;
                ModeJA = Mode1_A7;
                break;
            case "Mode1_B1":
                Repeat = 32;
                ModeJA = Mode1_B1;
                break;
            case "Mode1_B2":
                Repeat = 30;
                ModeJA = Mode1_B2;
                break;
            case "Mode1_B3":
                Repeat = 28;
                ModeJA = Mode1_B3;
                break;
            case "Mode1_B4":
                Repeat = 26;
                ModeJA = Mode1_B4;
                break;
            case "Mode1_C1":
                Repeat = 26;
                ModeJA = Mode1_C1;
                break;
            case "Mode1_C2":
                Repeat = 24;
                ModeJA = Mode1_C2;
                break;
            case "Mode1_C3":
                Repeat = 24;
                ModeJA = Mode1_C3;
                break;
        }
    } else if (Type === "2") {//內聚過度視力訓練

    } else if (Type === "5") {//內聚不足階梯訓練
        Repeat = 60;
        switch (Mode) {
            case "Mode5_A1":
                ModeJA = Mode5_A1;
                break;
            case "Mode5_A2":
                ModeJA = Mode5_A2;
                break;
            case "Mode5_A3":
                ModeJA = Mode5_A3;
                break;
            case "Mode5_A4":
                ModeJA = Mode5_A4;
                break;
            case "Mode5_A5":
                ModeJA = Mode5_A5;
                break;
            case "Mode5_A6":
                ModeJA = Mode5_A6;
                break;
            case "Mode5_A7":
                ModeJA = Mode5_A7;
                break;
            case "Mode5_B1":
                ModeJA = Mode5_B1;
                break;
            case "Mode5_B2":
                ModeJA = Mode5_B2;
                break;
            case "Mode5_B3":
                ModeJA = Mode5_B3;
                break;
            case "Mode5_B4":
                ModeJA = Mode5_B4;
                break;
            case "Mode5_C1":
                ModeJA = Mode5_C1;
                break;
            case "Mode5_C2":
                ModeJA = Mode5_C2;
                break;
            case "Mode5_C3":
                ModeJA = Mode5_C3;
                break;
            case "Mode5_C4":
                ModeJA = Mode5_C4;
                break;
            default:
                Repeat = 0;
                break;
        }
    } else if (Type === "6") {//內聚過度視力訓練

    }

    //Check
    if (ModeJA.length === 0) {
        SAlert("沒有指令資料");
        return;
    } else if (ModeJA.length > 50) {
        SAlert("指令超過大小限制");
        return;
    }
    //Set Mode
    Mode = "Mode" + Type + "_" + Mode;
    //Convert
    let ConvertModeJA = ConvertToDegreeJA(ModeJA);//稜鏡度換算為角度
    //Prepare
    let JOB = {
        Mode: Mode,
        Repeat: Repeat,
        ModeJA: ConvertModeJA
    }
    CallAppFunc("sendMsg", "Set_StartTrainMode", JSON.stringify(JOB));
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
        let Direction = Mode[1];
        let Prism = Mode[2];
        let Stay = Mode[3];
        let Degree = Direction * ConvertToDegree(Prism);
        ConvertModeJA.push([Arrive, Degree, Stay])
    }
    return ConvertModeJA;
}

//Bluetooth=============================================================================================================
function BTMsgReceive(Value) {
    let JOB = GetJOB(Value);
    let Cmd = JOBStrGet(JOB, "Cmd");
    let Res = JOBStrGet(JOB, "Res");
    let MsgJOB = JOBStrGetInit(JOB, "MsgJOB", {});
    if (Cmd === "Get_RealTimeInfo") {
        Get_RealTimeInfo(Res, MsgJOB);
        //BTMsgReceiveEx
        if (typeof Get_RealTimeInfoEx === "function") Get_RealTimeInfoEx(Res, MsgJOB);
    } else if (Cmd === "Set_StartTrainMode") {
        Set_StartTrainMode(Res);
        //Set_StartTrainModeEx
        if (typeof Set_StartTrainModeEx === "function") Set_StartTrainModeEx(Res);
    }
}

function Get_RealTimeInfo(Res, MsgJOB) {
    if (Res === "1") {
        let CMode = JOBStrGet(MsgJOB, "CMode");
        // let CDegree = JOBNumGet(MsgJOB, "CDegree");
        let CProgress = JOBStrGet(MsgJOB, "CProgress");
        let Training = JOBStrGet(MsgJOB, "Training");
        let EstTrainRemainM = JOBStrGet(MsgJOB, "EstTrainRemainM");
        if (Training) {
            //CType
            let pCType = GetEID("pCType");
            if (CMode.includes("Mode1")) pCType.innerText = "內聚不足視力訓練";
            else if (CMode.includes("Mode2")) pCType.innerText = "內聚過度視力訓練";
            else if (CMode.includes("Mode3")) pCType.innerText = "聚散能力檢測";
            else pCType.innerText = "";
            //CMode
            let pCMode = GetEID("pCMode");
            if (CMode.includes("A1")) pCMode.innerText = "基礎訓練(1)";
            else if (CMode.includes("A2")) pCMode.innerText = "基礎訓練(2)";
            else if (CMode.includes("A3")) pCMode.innerText = "基礎訓練(3)";
            else if (CMode.includes("A4")) pCMode.innerText = "基礎訓練(4)";
            else if (CMode.includes("A5")) pCMode.innerText = "基礎訓練(5)";
            else if (CMode.includes("A6")) pCMode.innerText = "基礎訓練(6)";
            else if (CMode.includes("A7")) pCMode.innerText = "基礎訓練(7)";
            else if (CMode.includes("B1")) pCMode.innerText = "提升訓練(1)";
            else if (CMode.includes("B2")) pCMode.innerText = "提升訓練(2)";
            else if (CMode.includes("B3")) pCMode.innerText = "提升訓練(3)";
            else if (CMode.includes("B4")) pCMode.innerText = "提升訓練(4)";
            else if (CMode.includes("C1")) pCMode.innerText = "進階訓練(1)";
            else if (CMode.includes("C2")) pCMode.innerText = "進階訓練(2)";
            else if (CMode.includes("C3")) pCMode.innerText = "進階訓練(3)";
            else if (CMode.includes("E1")) pCMode.innerText = "自主檢查(1)";
            else if (CMode.includes("E2")) pCMode.innerText = "自主檢查(2)";
            else if (CMode.includes("G")) pCMode.innerText = "實驗中";
            else if (CMode.includes("H")) pCMode.innerText = "耐久測試中";
            else if (CMode.includes("BO")) pCMode.innerText = "BO 檢測中";
            else if (CMode.includes("BI")) pCMode.innerText = "BI 檢測中";
            else pCMode.innerText = "";
            //CProgress
            let divProgress = GetEID("divProgress");
            divProgress.style.width = CProgress + "%";
            divProgress.innerText = CProgress + "%";
        }
        //CDegree
        CDegreeHandler(MsgJOB, "CDeg_L1", "divArrow_L", "pCDegree_L");
        CDegreeHandler(MsgJOB, "CDeg_R1", "divArrow_R", "pCDegree_R");
        //EstTrainRemainM
        let pRemainTime = GetEID("pRemainTime");
        if (pRemainTime != null) pRemainTime.innerText = MsToTime(EstTrainRemainM);
        //TrainingShow Handler
        if (Training && !isTraining) {
            isTraining = Training;
            $("#divNormal").fadeOut(function () {
                $("#divRun").fadeIn();
            });
        } else if (!Training && isTraining) {
            isTraining = Training;
            $("#divRun").fadeOut(function () {
                $("#divNormal").fadeIn();
            });
        }
    }
}

function CDegreeHandler(MsgJOB, CDegKey, divArrow, pCDegree) {
    //CDegree
    let CDegree = JOBNumGet(MsgJOB, CDegKey);
    let BasicDeg = 22;
    let CDegreeArrow = 0;
    if (CDegree === 0) CDegreeArrow = 0;
    else if (CDegree > 0 && CDegree < 30) CDegreeArrow = BasicDeg;
    else if (CDegree >= 30 && CDegree < 49) CDegreeArrow = BasicDeg * 2;
    else if (CDegree >= 49) CDegreeArrow = BasicDeg * 3;
    else if (CDegree < 0 && CDegree > -15) CDegreeArrow = -BasicDeg;
    else if (CDegree <= -15 && CDegree > -30) CDegreeArrow = -BasicDeg * 2;
    else if (CDegree <= -30) CDegreeArrow = -BasicDeg * 3;

    if (CDegKey.includes("R")) CDegreeArrow = -CDegreeArrow;
    GetEID(divArrow).style.transform = "rotate(" + CDegreeArrow + "deg)";
    //ShowDeg
    let ShowDeg = "";
    if (CDegree > 0) ShowDeg = "BO ";
    else if (CDegree < 0) ShowDeg = "BI ";
    ShowDeg += ConvertToPrism(CDegree);
    GetEID(pCDegree).innerText = ShowDeg;
}

function Set_StartTrainMode(Res) {
    if (Res === "3") SAlert("解析失敗");
    else if (Res === "4") SAlert("指令超過裝置大小限制");
}

