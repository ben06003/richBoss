//View
let cvChart;
let divTrainHisItemTmp, divCheckHisItemTmp;

window.onload = function () {
    top.SetHeaderInfo("歷史紀錄");
    //Init
    GetEID("inMonth").valueAsDate = addHours(new Date(), 8);
    divTrainHisItemTmp = GetEID("divTrainHisItem");
    divCheckHisItemTmp = GetEID("divCheckHisItem");
    GetEID("divTrainHisList").innerHTML = null;
    GetEID("divCheckHisList").innerHTML = null;
    InitChart();
    //Fetch
    Get_MonthHistory();
    ModeSelectHandler(GetEID("btTrain"));
}

//View==================================================================================================================
function ModeSelectHandler(El) {
    let btTrain = GetEID("btTrain");
    let btCheck = GetEID("btCheck");
    let divTrainHis = GetEID("divTrainHis");
    let divCheckHis = GetEID("divCheckHis");
    //btTrain
    if (El.id === btTrain.id) {
        ClassAdder(btTrain, "selectedColor");
        ClassRemover(divTrainHis, "hidden")
    } else {
        ClassRemover(btTrain, "selectedColor");
        ClassAdder(divTrainHis, "hidden");
    }
    //btCheck
    if (El.id === btCheck.id) {
        ClassAdder(btCheck, "selectedColor");
        ClassRemover(divCheckHis, "hidden")
    } else {
        ClassRemover(btCheck, "selectedColor");
        ClassAdder(divCheckHis, "hidden");
    }
}


function ShowHistoryInfo(InfoJOB) {
    let TrainHisJA = InfoJOB["TrainHisJA"];
    let CheckHisJA = InfoJOB["CheckHisJA"];
    //Chart
    ShowChart(InfoJOB);
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
    //CheckHis List
    let divCheckHisList = GetEID("divCheckHisList");
    divCheckHisList.innerHTML = null;
    for (let cnt = 0; cnt < CheckHisJA.length; cnt++) {
        let JOB = CheckHisJA[cnt];
        let divCheckHisItem = CloneEl(divCheckHisItemTmp);
        GetEID("pETimeC", divCheckHisItem).innerText = GetDateTime(JOBStrGet(JOB, "ETime"));
        GetEID("pScore", divCheckHisItem).innerText = JOBStrGet(JOB, "Score") + " 分";
        GetEID("pPrism", divCheckHisItem).innerText = JOBStrGet(JOB, "Prism") + " 度";
        divCheckHisList.appendChild(divCheckHisItem);
    }
}


function InitChart() {
    cvChart = new Chart(GetEID("cvChart"), {
        options: {
            scales: {

            }
        }
    });
}

function ShowChart(InfoJOB) {
    // console.log(InfoJOB);
    let TrainHisJA = InfoJOB["TrainHisJA"];//需要先反轉順序
    let CheckHisJA = InfoJOB["CheckHisJA"];//需要先反轉順序
    //Date
    let dateKeyJOB = {};
    //Train His
    if (TrainHisJA != null) {
        TrainHisJA = TrainHisJA.reverse();//需要反轉順序
        for (let cnt = 0; cnt < TrainHisJA.length; cnt++) {
            let JOB = TrainHisJA[cnt];
            let date = GetDate(JOBStrGet(JOB, "ETime"));
            let dayHisJA = dateKeyJOB[date];
            if (dayHisJA == null) dayHisJA = [];
            JOB["type"] = "train";
            dayHisJA.push(JOB);
            dateKeyJOB[date] = dayHisJA;
        }
    }
    //Check His
    if (CheckHisJA != null) {
        CheckHisJA = CheckHisJA.reverse();//需要反轉順序
        for (let cnt = 0; cnt < CheckHisJA.length; cnt++) {
            let JOB = CheckHisJA[cnt];
            let date = GetDate(JOBStrGet(JOB, "ETime"));
            let dayHisJA = dateKeyJOB[date];
            if (dayHisJA == null) dayHisJA = [];
            JOB["type"] = "check";
            dayHisJA.push(JOB);
            dateKeyJOB[date] = dayHisJA;
        }
    }
    //轉換為Chart
    let trainTimesAry = [], checkScoreAry = [];
    let dateAry = Object.keys(dateKeyJOB);
    for (let cnt = 0; cnt < dateAry.length; cnt++) {
        let dayHisJA = dateKeyJOB[dateAry[cnt]];
        let trainTimes = 0;
        let checkScore = 0;
        for (let cntA = 0; cntA < dayHisJA.length; cntA++) {
            let JOB = dayHisJA[cntA];
            let type = JOBStrGet(JOB, "type");
            if (type === "train") {
                trainTimes++;
            } else if (type === "check") {
                let score = JOBNumGet(JOB, "Score");
                if (score > checkScore) checkScore = score;
            }
        }
        trainTimesAry.push(trainTimes);
        checkScoreAry.push(checkScore);
    }

    cvChart.data = {
        datasets: [{
            type: 'bar',
            label: '訓練次數',
            data: trainTimesAry
        }, {
            type: 'line',
            label: '檢測分數',
            data: checkScoreAry,
        }],
        labels: dateAry
    }
    cvChart.update();

}

//Network===============================================================================================================
function Get_MonthHistory() {
    //Read
    let YearMonth = GetEID("inMonth").value;
    let date = new Date(YearMonth);
    //Prepare
    let SendJOB = {
        year: date.getFullYear(),
        month: (date.getMonth() + 1),
        mode: "month"
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