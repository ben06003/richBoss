let recordNum;//已記錄次數
let blurPos = 0, breakPos = 0, recoverPos = 0;//模糊點,破裂點,恢復點
let isTrainingEx = false;//是否正在檢測
let goRecordSize = 0;//去程結束時 紀錄 recordAry 的大小
let CMode = "", CModePos, CDeg_L1 = 0;//當前模式,當前執行步驟,當前角度(參考左眼)
window.onload = function () {
    if (isApp()) {
        //Func
        StopTrain();//先停止訓練，因為可能來自其他地方正在訓練
        Init();//更新資訊
        InitBtRecord();//初始化紀錄按紐
        GoStepHandler(0);//顯示正常View
        UpdateHistoryView().then();//顯示歷史紀錄
        optotypeSelectHandler(GetEID("divOptotype"), 1);//初始化視標選擇
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
    let divStep2 = GetEID("divStep2");
    if (step === 0) {
        $(divStep2).fadeOut(300, async function () {
            ClassAdder(divStep1, "hidden");
            ClassAdder(divStep2, "hidden");
            $(divNormal).fadeIn(600, function () {
                ClassRemover(divNormal, "hidden");
            });
        });
    } else if (step === 1) {
        $(divNormal).fadeOut(300, async function () {
            ClassAdder(divNormal, "hidden");
            ClassAdder(divStep2, "hidden");
            $(divStep1).fadeIn(600, function () {
                ClassRemover(divStep1, "hidden");
            });
        });
    } else if (step === 2) {
        $(divStep1).fadeOut(300, async function () {
            //btRecord
            let btRecord = GetEID("btRecord");
            btRecord.innerText = "按我開始";
            btRecord.dataset.type = type;
            //View
            ClassAdder(divNormal, "hidden");
            ClassAdder(divStep1, "hidden");
            $(divStep2).fadeIn(600, function () {
                ClassRemover(divStep2, "hidden");
            });
        });
    }
}

function InitBtRecord() {
    GetEID("btRecord").addEventListener('click', function () {
        if (isTrainingEx) RecordPos();
        else {
            let type = GetEID("btRecord").dataset.type;
            if (type === "BO" || type === "BI") StartGatherTest(type);
            else SAlert("偵測到遺失資訊");
        }
    });
}

//History Record========================================================================================================
function RecordPos() {
    if (CModePos === 1) {//前往 30
        if (recordNum === 0) {
            breakPos = CDeg_L1;
            recordNum++;
            ShowRecordPosTmp();
        } else if (recordNum === 1) {
            blurPos = breakPos;
            breakPos = CDeg_L1;
            recordNum++;
            ShowRecordPosTmp();
        } else SAlert("已超過記錄次數", "請稍待返回時手動紀錄恢復點");
    } else if (CModePos === 2) {//返回 0
        if (goRecordSize === recordNum) {
            recoverPos = CDeg_L1;
            ShowRecordPosTmp();
            StopTrain();//結束程序停止檢測
        } else SAlert("已超過記錄次數", "請稍待程序完成");
    }
}

function ShowRecordPosTmp() {
    GetEID("pBlur").innerText = ConvertToPrism(blurPos).toString();
    GetEID("pBreak").innerText = ConvertToPrism(breakPos).toString();
    GetEID("pRecover").innerText = ConvertToPrism(recoverPos).toString();
}

async function UpdateHistoryView() {
    let BOKey = "GT_Mode3_BO";
    let BIKey = "GT_Mode3_BI";
    let recordAryBO = await GetStorage(BOKey);
    let recordAryBI = await GetStorage(BIKey);
    //BO
    if (Array.isArray(recordAryBO)) {
        if (recordAryBO.length === 2) {
            GetEID("pBlurBO").innerText = "0";
            GetEID("pBreakBO").innerText = ConvertToPrism(recordAryBO[0]).toString();
            GetEID("pRecoverBO").innerText = ConvertToPrism(recordAryBO[1]).toString();
        } else if (recordAryBO.length > 2) {
            GetEID("pBlurBO").innerText = ConvertToPrism(recordAryBO[0]).toString();
            GetEID("pBreakBO").innerText = ConvertToPrism(recordAryBO[1]).toString();
            GetEID("pRecoverBO").innerText = ConvertToPrism(recordAryBO[2]).toString();
        }
    }
    //BI
    if (Array.isArray(recordAryBI)) {
        if (recordAryBI.length === 2) {
            GetEID("pBlurBI").innerText = "0";
            GetEID("pBreakBI").innerText = ConvertToPrism(recordAryBI[0]).toString();
            GetEID("pRecoverBI").innerText = ConvertToPrism(recordAryBI[1]).toString();
        } else if (recordAryBI.length > 2) {
            GetEID("pBlurBI").innerText = ConvertToPrism(recordAryBI[0]).toString();
            GetEID("pBreakBI").innerText = ConvertToPrism(recordAryBI[1]).toString();
            GetEID("pRecoverBI").innerText = ConvertToPrism(recordAryBI[2]).toString();
        }
    }
}

//Step2 Handler=========================================================================================================
let preDivOptotype;

function optotypeSelectHandler(divOptotype, optotype) {
    if (preDivOptotype === divOptotype) return;
    ClassAdder(divOptotype, "border-4");
    if (preDivOptotype != null) ClassRemover(preDivOptotype, "border-4");
    preDivOptotype = divOptotype;
    //Update optotype
    let maxHeight = "";
    let imgOptotype = GetEID("imgOptotype");
    switch (optotype) {
        case 1:
            maxHeight = "30mm";
            break;
        case 2:
            maxHeight = "25mm";
            break;
        case 3:
            maxHeight = "20mm";
            break;
        case 4:
            maxHeight = "15mm";
            break;
        case 5:
            maxHeight = "10mm";
            break;
        case 6:
            maxHeight = "5mm";
            break;
    }
    imgOptotype.style.maxHeight = maxHeight;
}

//Start Gather Test
function StartGatherTest(type) {
    let Mode = "Mode3_";
    let ModeJA = [];
    //Check
    if (type === "BO") {
        Mode += "BO"
        ModeJA = Mode3_BO;
    } else if (type === "BI") {
        Mode += "BI"
        ModeJA = Mode3_BI;
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
        let CModePosTmp = JOBNumGet(MsgJOB, "CModePos");
        let Training = JOBStrGet(MsgJOB, "Training");
        CDeg_L1 = JOBNumGet(MsgJOB, "CDeg_L1");
        //CModePos 剛執行返回時
        if (CModePosTmp !== CModePos && CModePosTmp === 2) {
            goRecordSize = recordNum;
        }
        CModePos = CModePosTmp;
        //Training
        if (!Training && isTrainingEx) {//檢測結束
            //紀錄資訊
            if (CMode.includes("Mode3_")) {
                if (breakPos !== 0 && recoverPos !== 0) {
                    //Build recordAry
                    let recordAry = [];
                    if (blurPos !== 0) recordAry.push(blurPos);
                    recordAry.push(breakPos);
                    recordAry.push(recoverPos);
                    //Save recordAry
                    let Key = "GT_" + CMode;
                    SetStorage(Key, recordAry).then(() => {
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
        recordNum = 0;//Clear
        blurPos = 0;//Clear
        breakPos = 0;//Clear
        recoverPos = 0;//Clear
        goRecordSize = 0;//Clear
        ShowRecordPosTmp();//Clear
        GetEID("btRecord").innerText = "按我紀錄";
    }
}
