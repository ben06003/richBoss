window.onload = function () {
    StopTrain();//停止當前的訓練
    CallAppFunc("setOrientation", "land");//設為橫向
    Get_MonthHistory();
}

//Show suggest
function ShowLevelSuggest(InfoJOB) {
    let head = "依據AI檢測紀錄\n智能推薦您挑戰 關卡";
    let pSuggest = GetEID("pSuggest");
    let CheckHisJA = InfoJOB["CheckHisJA"];
    if (CheckHisJA.length > 0) {
        let JOB = CheckHisJA[0];
        let prism = JOBNumGet(JOB, "Prism");
        let level = Math.round(prism / 2) + 1;
        if (level > 16) level = 16;
        pSuggest.innerText = head + level;
    } else {
        pSuggest.innerText = "無資料";
    }
    ClassRemover(pSuggest, "invisible")
    $(pSuggest).fadeIn(500);
}

//呼叫前往訓練
function SelectLevel(level) {
    let prism = level * 2;
    let query = "header=Level&prism=" + prism
    top.GoPage("Page_Train_AITrain", query);
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
            ShowLevelSuggest(ResJOB["InfoJOB"]);
        } else {
            SAlert("未知的回應", "ResCode:" + ResCode + " ResMsg:" + ResMsg);
        }
    }, "Get_MonthHistory", SendJOB);
}