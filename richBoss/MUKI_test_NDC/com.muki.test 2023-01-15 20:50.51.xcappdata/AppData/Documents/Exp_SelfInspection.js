let pRecordTmp;
let PreCMode = "", CMode = "", CModePos = 0, CDegree = 0;
window.onload = function () {
    pRecordTmp = GetEID("pRecord");
    GetEID("divRecordList").innerHTML = null;
    //Func
    if (isApp()) {
        StopTrain();//先停止訓練，因為可能來自其他地方正在訓練
        Init();
        ShowRecordList().then();
    }
}

//Record================================================================================================================
async function ShowRecordList() {
    let Mode = GetEID("slMode").value;
    let pRecordTitle = GetEID("pRecordTitle");
    let divRecordList = GetEID("divRecordList");
    if (Mode === "E1") {
        pRecordTitle.innerText = "歷史紀錄(1)";
    } else if (Mode === "E2") {
        pRecordTitle.innerText = "歷史紀錄(2)";
    }
    //Show List
    divRecordList.innerHTML = null;
    $(divRecordList).fadeOut(200, async function () {
        for (let cnt = 0; cnt < 3; cnt++) {
            let Key = "SC_" + Mode + "_" + cnt;
            let Value = await GetStorage(Key);
            let pRecord = CloneEl(pRecordTmp);
            pRecord.innerText = Value;
            divRecordList.appendChild(pRecord);
        }
        $(divRecordList).fadeIn(500);
    });

}

let RTimes = 0;//目前記錄的次數

function RecordPos() {
    let Key = "SC_" + CMode + "_" + RTimes;
    //Convert
    let Prism = "";
    if (CDegree > 0) Prism = "BO ";
    else if (CDegree < 0) Prism = "BI ";
    Prism += ConvertToPrism(CDegree);
    //Save
    if (CModePos === 2) {
        if (RTimes < 2) {
            SetStorage(Key, Prism).then(() => {
                ShowRecordList().then();//更新清單
            });
            RTimes++;
            //立即執行下個動作
            if (RTimes === 2) {
                CallAppFunc("sendMsg","Set_RunNextMode");
            }
        } else {
            CallAppFunc("uiToast","請等待返回中才能紀錄");
        }
    } else if (CModePos === 3 && RTimes === 2) {
        SetStorage(Key, Prism).then(() => {
            StopTrain();//已達成紀錄次數 立即停止
        });
        RTimes++;
    }
}

async function ClearRecord() {
    let Mode = GetEID("slMode").value;
    for (let cnt = 0; cnt < 3; cnt++) {
        let Key = "SC_" + Mode + "_" + cnt;
        await SetStorage(Key, "");
    }
}

//Bluetooth=============================================================================================================
function Get_RealTimeInfoEx(Res, MsgJOB) {
    if (Res === "1") {
        let CModeTmp = JOBStrGet(MsgJOB, "CMode");
        //RealTime Data
        if (CModeTmp.length > 0) {
            CMode = JOBStrGet(MsgJOB, "CMode");
            CDegree = JOBNumGet(MsgJOB, "CDegree");
            CModePos = JOBNumGet(MsgJOB, "CModePos");
        }
        //RTimes Handler
        if (CModeTmp !== PreCMode) {
            if (CModeTmp.length > 0) {//開始記錄
                ClassRemover(GetEID("btRecord"), "hidden");
                //清除紀錄
                ClearRecord().then(() => {
                    ShowRecordList().then();//更新紀錄
                });
            } else {//紀錄結束
                ClassAdder(GetEID("btRecord"), "hidden");//隱藏記錄按鈕
                ShowRecordList().then();//更新紀錄
            }
            RTimes = 0;//Clear
            PreCMode = CModeTmp;
        }
    }
}
