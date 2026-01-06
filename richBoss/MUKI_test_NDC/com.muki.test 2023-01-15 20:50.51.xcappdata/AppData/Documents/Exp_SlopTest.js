let record = 0;//角度暫存紀錄
let isTrainingEx = false;//是否正在檢測
let CMode = "", CModePos, CDeg_L1 = 0;//當前模式,當前執行步驟,當前角度(參考左眼)
window.onload = function () {
    if (isApp()) {
        //Func
        StopTrain();//先停止訓練，因為可能來自其他地方正在訓練
        Init();//更新資訊
        InitBtRecord();//初始化紀錄按紐
        GoStepHandler(0);//顯示正常View
        UpdateHistoryView().then();//顯示歷史紀錄
        //Show body
        setTimeout(function () {
            $(document.body).fadeIn(500);
        }, 300);
    }
}

//View Step=============================================================================================================
function GoStepHandler(step, type = "") {
    let divNormal = GetEID("divNormal");
    let divStep1 = GetEID("divStep1");
    if (step === 0) {
        $(divStep1).fadeOut(300, async function () {
            ClassAdder(divStep1, "hidden");
            $(divNormal).fadeIn(600, function () {
                ClassRemover(divNormal, "hidden");
            });
        });
    } else if (step === 1) {
        $(divNormal).fadeOut(300, async function () {
            //btRecord
            let btRecord = GetEID("btRecord");
            btRecord.innerText = "按我開始";
            btRecord.dataset.type = type;
            //Update Image
            GetEID("imgSlop").style.transform = type === "BO" ? "rotate(0deg)" : "rotate(180deg)";
            //View
            ClassAdder(divNormal, "hidden");
            $(divStep1).fadeIn(600, function () {
                ClassRemover(divStep1, "hidden");
            });
        });
    }
}

function InitBtRecord() {
    GetEID("btRecord").addEventListener('click', function () {
        if (isTrainingEx) RecordPos();
        else {
            let type = GetEID("btRecord").dataset.type;
            if (type === "BO" || type === "BI") StartSlopTest(type);
            else SAlert("偵測到遺失資訊");
        }
    });
}

//History Record========================================================================================================
function RecordPos() {
    if (CModePos === 1) {//前往 30 中
        if (record === 0) {
            record = CDeg_L1;
            StopTrain();//立即停止檢測
        }
    } else if (CModePos === 2) {//返回 0
        SAlert("返回中無法紀錄");
    }
}

async function UpdateHistoryView() {
    let BOKey = "SL_Mode4_BO";
    let BIKey = "SL_Mode4_BI";
    let recordBO = await GetStorage(BOKey);
    let recordBI = await GetStorage(BIKey);
    //BO
    if (typeof recordBO === 'number') {
        GetEID("pSlopBO").innerText = ConvertToPrism(recordBO).toString();
    }
    //BI
    if (typeof recordBI === 'number') {
        GetEID("pSlopBI").innerText = ConvertToPrism(recordBI).toString();
    }
}

//Start Slop Test
function StartSlopTest(type) {
    let Mode = "Mode4_";
    let ModeJA = [];
    //Check
    if (type === "BO") {
        Mode += "BO"
        ModeJA = Mode4_BO;
    } else if (type === "BI") {
        Mode += "BI"
        ModeJA = Mode4_BI;
    }
    //Save
    CMode = Mode;
    //Convert
    let ConvertModeJA = ConvertToDegreeJA(ModeJA);//稜鏡度換算為角度
    //Prepare
    let JOB = {
        Mode: Mode,
        Repeat: 0,
        ModeJA: ConvertModeJA
    }
    CallAppFunc("sendMsg", "Set_StartTrainMode", JSON.stringify(JOB));
}


//Bluetooth=============================================================================================================
function Get_RealTimeInfoEx(Res, MsgJOB) {
    if (Res === "1") {
        let Training = JOBStrGet(MsgJOB, "Training");
        let CMode = JOBStrGet(MsgJOB, "CMode");
        CModePos = JOBNumGet(MsgJOB, "CModePos");
        CDeg_L1 = JOBNumGet(MsgJOB, "CDeg_L1");
        //Training
        if (!Training && isTrainingEx) {//檢測結束
            //紀錄資訊
            if (CMode.includes("Mode4_")) {
                if (record !== 0) {
                    let Key = "SL_" + CMode;
                    SetStorage(Key, record).then(() => {
                        UpdateHistoryView().then();//更新歷史紀錄頁面
                        GoStepHandler(0);//回到一般畫面
                    });
                } else {
                    GoStepHandler(0);//回到一般畫面
                    SAlert("提供資訊不足", "系統無法蒐集足夠的資訊作為正式之紀錄");
                }
            }
        }
        isTrainingEx = Training;
    }
}


function Set_StartTrainModeEx(Res) {
    if (Res === "1") {//已開始檢測
        record = 0;//Clear
        GetEID("btRecord").innerText = "按我紀錄";
    }
}
