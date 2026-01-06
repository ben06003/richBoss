window.onload = function () {
    StopTrain();//停止當前的訓練
    InitPage2EList();//顯示視標清單
    ShowPage(1);//顯示初始畫面
}

//View==================================================================================================================
function InitPage2EList() {
    //Param
    let imgUrl = "/app/image/Page_Train_Smart/ic_crutch.png";
    let ParseURL = new URL(location.href);
    let Params = ParseURL.searchParams;
    let next = GetParam(Params, "next");
    if (next === "Smart") imgUrl = "/app/image/Page_Train_Smart/ic_vision_e.png";
    //List
    let divPage2EList = GetEID("divPage2EList");
    let divPage2ETmp = GetEID("divPage2E");
    if (next !== "Smart") ClassAdder(GetEID("pEPage2", divPage2ETmp), "hidden");//隱藏參數
    divPage2EList.innerHTML = null;
    for (let cnt = 0; cnt < 6; cnt++) {
        //targetPT & showDesc
        let targetPT = 20, showDesc = "";
        switch (cnt) {
            case 0:
                targetPT = 20;
                showDesc = "20/100";
                break;
            case 1:
                targetPT = 16;
                showDesc = "20/80";
                break;
            case 2:
                targetPT = 12;
                showDesc = "20/60";
                break;
            case 3:
                targetPT = 10;
                showDesc = "20/50";
                break;
            case 4:
                targetPT = 8;
                showDesc = "20/40";
                break;
            case 5:
                targetPT = 6;
                showDesc = "20/30";
                break;
        }
        //Show
        let divPage2E = CloneEl(divPage2ETmp);
        //pEPage2
        let pEPage2 = GetEID("pEPage2", divPage2E);
        pEPage2.innerText = showDesc;
        //imgEPage2
        let imgEPage2 = GetEID("imgEPage2", divPage2E);
        imgEPage2.src = imgUrl;
        imgEPage2.style.minHeight = targetPT + "pt";
        imgEPage2.style.maxHeight = targetPT + "pt";
        divPage2E.addEventListener("click", () => {
            let imgEPage3 = GetEID("imgEPage3");
            imgEPage3.src = imgUrl;
            imgEPage3.style.minHeight = targetPT + "pt";
            imgEPage3.style.maxHeight = targetPT + "pt";
            ShowPage(3);
        })
        divPage2EList.appendChild(divPage2E);
    }
}

function ShowPage(pageId) {
    for (let cnt = 1; cnt <= 4; cnt++) {
        let divPage = GetEID("divPage" + cnt);
        if (pageId === cnt) {
            $(divPage).fadeIn(500);
            divPage.style.display = "flex";
        } else {
            divPage.style.display = "none";
        }
    }
}

function GoPage1Next() {
    //Param
    let ParseURL = new URL(location.href);
    let Params = ParseURL.searchParams;
    let next = GetParam(Params, "next");
    if (next === "Smart") ShowPage(2);//智慧檢測才需要選擇
    else ShowPage(3);
}

function ShowSmartResult() {
    //Check Score
    const finalPrism = CPrism;
    let Score = finalPrism * 3.125;
    Score = Math.round(Score);
    if (Score > 100) Score = 100;
    else if (Score < 0) Score = 0;
    //Desc
    let Desc;
    if (Score >= 90) Desc = "視覺品質測驗很讚喔!\n要繼續保持喔!";
    else if (Score >= 75) Desc = "視覺品質測驗還不錯喔!\n要常常練習喔!";
    else if (Score >= 60) Desc = "視覺品質還需要加強練習呢!";
    else if (Score >= 30) Desc = "視覺品質不太理想呢!\n每天都要使用ORTHO智慧訓練機!";
    else Desc = "這個分數實在太慘啦\n每天都要使用ORTHO智慧訓練機\n提升我們的視覺品質";
    //Param
    let ParseURL = new URL(location.href);
    let Params = ParseURL.searchParams;
    let next = GetParam(Params, "next");
    //Show
    GetEID("lpReport").play();//播放動畫
    GetEID("pScore").innerText = Score.toString();
    GetEID("pPrism").innerText = finalPrism;
    GetEID("pDesc").innerText = Desc;
    //Next
    let btNext = GetEID("btNext");
    if (next === "AITrain") btNext.innerText = "前往AI訓練";
    else if (next === "Game") btNext.innerText = "前往趣味遊戲";
    else btNext.innerText = "結束檢測";
    btNext.addEventListener("click", function () {
        if (next === "AITrain") {//智慧訓練
            top.GoPage("Page_Train_AITrain", "header=AITrain&prism=" + Math.ceil(finalPrism))
        } else if (next === "Game") {//遊戲
            top.GoPage("Page_Train_Game");
        } else {//智慧檢測
            top.GoPage('Page_Train')
        }
    })
    //紀錄本次檢測結果
    Set_RecordCheck(finalPrism);
}

function BTRunHandler() {
    if (isTraining) {//停止檢測
        StopTrain();//停止檢測
        ShowPage(4);//前往結果頁面
        setTimeout(function () {
            ShowSmartResult();
        }, 200);
    } else {//開始檢測
        StartTrain("Check_1");//呼叫開始檢測
    }
}

//Bluetooth=============================================================================================================
let isTraining = false;
let CPrism = 0;//當前稜鏡量

function Get_RealTimeInfoEx(Res, MsgJOB) {
    if (Res === "1") {
        let CMode = JOBStrGet(MsgJOB, "CMode");
        let CDegree = JOBNumGet(MsgJOB, "CDeg_L1");//用單邊判斷即可
        let CProgress = JOBStrGet(MsgJOB, "CProgress");
        let Training = JOBStrGet(MsgJOB, "Training");
        let EstTrainRemainM = JOBStrGet(MsgJOB, "EstTrainRemainM");
        let TMode = JOBStrGet(CTrainInfoJOB, "TMode");
        if (CMode === TMode) {//檢測當前眼鏡運作的模式與現在相同
            if (Training) {
                //CProgress
                let divProgress = GetEID("divProgress");
                divProgress.style.width = CProgress + "%";
                divProgress.innerText = CProgress + "%";
                //EstTrainRemainM
                let pRemainTime = GetEID("pRemainTime");
                if (pRemainTime != null) pRemainTime.innerText = MsToTime(EstTrainRemainM);
                //CPrism
                CPrism = ConvertToPrism(CDegree, 1);
            }
            //TrainingShow Handler
            if (Training && !isTraining) {
                isTraining = Training;
                $("#divRun").fadeIn(500);
                GetEID("btRun").innerText = "圖像已分裂";
            } else if (!Training && isTraining) {
                isTraining = Training;
                $("#divRun").fadeOut(300);
                GetEID("btRun").innerText = "開始檢測";
            }
        }
    }
}

//Network===============================================================================================================
function Set_RecordCheck(prism) {
    let SendJOB = {
        prism: prism
    };
    SFetchClient(async function (ResJOB) {
        let ResCode = JOBStrGet(ResJOB, "ResCode");
        let ResMsg = JOBStrGet(ResJOB, "ResMsg");
        if (ResCode === "1") {//Success

        } else if (ResCode === "2") {
            SAlert("紀錄失敗", ResMsg);
        } else {
            SAlert("未知的回應", "ResCode:" + ResCode + " ResMsg:" + ResMsg);
        }
    }, "Set_RecordCheck", SendJOB);
}