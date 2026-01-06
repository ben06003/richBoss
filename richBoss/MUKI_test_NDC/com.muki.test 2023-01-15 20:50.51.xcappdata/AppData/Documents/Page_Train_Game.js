let divMouseTmp;
//Data
const mouseNum = 12;//地鼠總數量
let cPageId = 0;//當前頁面
let mouseHideDelay = 2000;//地鼠出現後多久隱藏，等級越高 速度越快
let currentShowMouseId = -1;//當前顯示地鼠的ID
let mouseTotalShows = 0;//地鼠總共出現次數
let mouseHitTimes = 0;//地鼠總共打到的次數

window.onload = function () {
    StopTrain();//停止只當前的訓練
    //View
    divMouseTmp = GetEID("divMouse");
    ShowPage(1);
}

//View==================================================================================================================
function ShowPage(pageId) {
    cPageId = pageId;
    for (let cnt = 1; cnt <= 3; cnt++) {
        let divPage = GetEID("divPage" + cnt);
        if (pageId === cnt) {
            $(divPage).fadeIn(500);
            divPage.style.display = "flex";
        } else {
            divPage.style.display = "none";
        }
    }
    //Check
    if (pageId === 3) {
        if (audioBack != null) audioBack.pause();
    }
}

function ShowGameResult() {
    //Check Score
    let score = Math.round(mouseHitTimes * 100 / mouseTotalShows);
    if (score > 100) score = 100;
    else if (score < 0) score = 0;
    //Desc
    let Desc;
    if (score >= 90) Desc = "遊戲分數實在是太高啦!\n您的視覺品質很棒喔!\n還是要偶爾練習喔!";
    else if (score >= 75) Desc = "遊戲分數還不錯呢!\n還是需要常常練習的\n讓我們的視覺品質加分吧!";
    else if (score >= 60) Desc = "視覺品質還需要加強練習呢\n每天都要使用ORTHO智慧訓練機";
    else if (score >= 30) Desc = "視覺品質不太理想呢\n每天都要使用ORTHO智慧訓練機";
    else Desc = "這個分數實在太慘啦\n每天都要使用ORTHO智慧訓練機";
    //Show
    GetEID("lpReport").play();//播放動畫
    GetEID("pScore").innerText = score.toString();
    GetEID("pDesc").innerText = Desc;
    ShowPage(3);
}

//Mouse=================================================================================================================
function ShowMouseList() {
    let divMouseList = GetEID("divMouseList");
    divMouseList.innerHTML = null;
    //Auto adjust div mouse width
    let divWidth = divMouseList.offsetWidth;
    let targetWidth = divWidth / 3;
    divMouseTmp.style.minWidth = targetWidth + "px";
    divMouseTmp.style.maxWidth = targetWidth + "px";
    //Show
    for (let cnt = 0; cnt < 12; cnt++) {
        let divMouse = CloneEl(divMouseTmp);
        divMouse.id = "divMouse_" + cnt;
        let imgMouse = GetEID("imgMouse", divMouse);
        imgMouse.addEventListener("click", function () {
            if (cnt === currentShowMouseId) {
                currentShowMouseId = -1;//必須清掉 避免重複計算
                imgMouse.src = "/app/image/Page_Train_Game/ic_mouse_cry.png";
                mouseHitTimes++;
                PlayHitAudio();
            }
        });
        divMouseList.appendChild(divMouse);
    }
}

function RandomShowMouse() {
    mouseTotalShows++;//計算地鼠總出現次數
    currentShowMouseId = Math.floor(Math.random() * mouseNum);
    let targetMouseDiv = GetEID("divMouse_" + currentShowMouseId);
    let imgMouse = GetEID("imgMouse", targetMouseDiv);
    ClassRemover(imgMouse, "mouseDown");
    ClassAdder(imgMouse, "mouseUp");
    //地鼠開始隱藏
    setTimeout(function () {
        ClassRemover(imgMouse, "mouseUp");
        ClassAdder(imgMouse, "mouseDown");
    }, mouseHideDelay);
    //取消可以打擊地鼠
    setTimeout(function () {
        currentShowMouseId = -1;
    }, mouseHideDelay + 200);
    //顯示下一隻地鼠
    setTimeout(function () {
        imgMouse.src = "/app/image/Page_Train_Game/ic_mouse_normal.png";//Reset image
        if (cPageId === 2) RandomShowMouse();
    }, mouseHideDelay + 600);
}

//Music=================================================================================================================
let audioBack;

function PlayBackgroundAudio() {
    audioBack = new Audio('/app/audio/Page_Train_Game/aud_back.mp3');
    audioBack.loop = true;
    audioBack.play().then();
}

function PlayHitAudio() {
    let audio = new Audio('/app/audio/Page_Train_Game/aud_hit.mp3');
    audio.play().then();
}

//Bluetooth=============================================================================================================
let isTraining = false;
let startTrainM;//開始訓練的時間

function Get_RealTimeInfoEx(Res, MsgJOB) {
    if (Res === "1") {
        let CMode = JOBStrGet(MsgJOB, "CMode");
        let Training = JOBStrGet(MsgJOB, "Training");
        let EstTrainRemainM = JOBStrGet(MsgJOB, "EstTrainRemainM");
        let TMode = JOBStrGet(CTrainInfoJOB, "TMode");
        if (CMode === TMode) {//檢測當前眼鏡運作的模式與現在相同
            if (Training) {
                //EstTrainRemainM
                let pRemainTime = GetEID("pRemainTime");
                if (pRemainTime != null) pRemainTime.innerText = Math.round(EstTrainRemainM / 1000).toString();//millis to sec
            }
            //TrainingShow Handler
            if (Training && !isTraining) {//訓練開始
                startTrainM = GetCurrentM();
                isTraining = Training;
                ShowPage(2);//顯示遊戲畫面
                ShowMouseList();//顯示清單
                PlayBackgroundAudio();//開始播放音樂
                setTimeout(function () {
                    mouseHitTimes = 0;//Reset
                    mouseTotalShows = 0;//Reset
                    RandomShowMouse();//開始隨機跑出地鼠
                }, 1500);
            } else if (!Training && isTraining) {//訓練結束
                isTraining = Training;
                //紀錄本次訓練內容
                Set_RecordTrain(true);
            }
        }
    }
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
            //Get recent prism
            let InfoJOB = ResJOB["InfoJOB"];
            let CheckHisJA = InfoJOB["CheckHisJA"];
            if (CheckHisJA.length > 0) {
                //呼叫開始訓練
                let JOB = CheckHisJA[0];
                let prism = Math.ceil(JOBNumGet(JOB, "Prism"));
                if (prism > 32) prism = 32;
                else if (prism < 1) prism = 1;
                //mouseHideDelay
                mouseHideDelay = 2000 - Math.round(prism * 45);
                //Start
                console.log("prism: " + prism);
                StartTrain("Game_" + prism);
            } else {
                SAsk("尚未有任何檢測的紀錄", "將引導您前往檢測", {CancelAble: false}).then(function (result) {
                    if (result.isConfirmed) {
                        top.GoPage("Page_Train_Smart", "next=Game");//呼叫檢測 完成後前往Game
                    } else {//取消返回訓練
                        top.GoPage("Page_Train");
                    }
                })
            }
        } else {
            SAlert("未知的回應", "ResCode:" + ResCode + " ResMsg:" + ResMsg);
        }
    }, "Get_MonthHistory", SendJOB);
}

function Set_RecordTrain(Finish) {
    //Prepare
    let TMode = JOBStrGet(CTrainInfoJOB, "TMode");
    let MName = JOBStrGet(CTrainInfoJOB, "MName");
    let TTime = (GetCurrentM() - startTrainM) / 1000;//訓練總時間
    let SendJOB = {
        TMode: TMode,
        MName: MName,
        TTime: TTime,
        Finish: Finish ? "T" : "F"
    };
    SFetchClient(function (ResJOB) {
        let ResCode = JOBStrGet(ResJOB, "ResCode");
        let ResMsg = JOBStrGet(ResJOB, "ResMsg");
        if (ResCode === "1") {//Success

        } else if (ResCode === "2") {
            SAlert("紀錄失敗", ResMsg);
        } else {
            SAlert("未知的回應", "ResCode:" + ResCode + " ResMsg:" + ResMsg);
        }
        setTimeout(() => {
            ShowGameResult();//顯示遊戲結果
        }, ResCode === "1" ? 0 : 2500)
    }, "Set_RecordTrain", SendJOB, {}, (ResCode, ResMsg) => {
        SAlert("紀錄失敗", ResMsg);
        setTimeout(() => {
            ShowGameResult();//顯示遊戲結果
        }, 2500);
    });
}
