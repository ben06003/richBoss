let cPageId = -1;
let canReceiveBTMsg = true;//用於阻斷藍芽訊息
window.onload = function () {
    StopTrain();//停止只當前的訓練
    CallAppFunc("setOrientation", "land");//設為橫向
    ShowPage(1);//顯示初始畫面
}

//View==================================================================================================================
function ShowPage(pageId) {
    cPageId = pageId;
    for (let cnt = 1; cnt <= 2; cnt++) {
        let divPage = GetEID("divPage" + cnt);
        if (pageId === cnt) {
            $(divPage).fadeIn(500);
            divPage.style.display = "flex";
        } else {
            divPage.style.display = "none";
        }
    }
}

function StartTrainHandler() {
    ShowPage(2);//顯示訓練頁面
    setTimeout(function () {//讓畫面變更好 再開始訓練
        //透過Prism選擇要執行的訓練
        let ParseURL = new URL(window.location.href);
        let Params = ParseURL.searchParams;
        let header = GetParam(Params, "header");
        let prism = GetParam(Params, "prism");
        if (header.length > 0 && isNumeric(prism)) {
            prism = parseInt(prism);
            StartTrain(header + "_" + prism);//呼叫開始訓練
        } else {
            SAlert("傳入了錯誤參數", prism);
        }
    }, 500);
}

function StopTrainHandler() {
    SAsk("確認要立即結束訓練?").then(result => {
        if (result.isConfirmed) {
            StopTrain();//呼叫裝置停止
            //紀錄本次訓練內容
            canReceiveBTMsg = false;
            Set_RecordTrain(false);
        }
    });
}

//Words=================================================================================================================
let WordsJA = [
    {name: "camel", file: "animal_rakuda_kobu_tareru.png"},
    {name: "hedgehog", file: "animal_tenrec.png"},
    {name: "kangaroo", file: "animal_wallaby_kangaroo.png"},
    {name: "baseball", file: "baseball_ball.png"},
    {name: "woodpecker", file: "bird_kumagera.png"},
    {name: "owl", file: "bird_shima_fukurou.png"},
    {name: "bread", file: "bread_syokupan_5maigiri.png"},
    {name: "bee", file: "bug_mitsubachi.png"},
    {name: "mailbox", file: "character_post.png"},
    {name: "programming", file: "computer_programming_man.png"},
    {name: "dinosaur", file: "dinosaur_allosaurus.png"},
    {name: "fashion", file: "fashion_show_woman.png"},
    {name: "watermelon", file: "fruit_suika_kodama.png"},
    {name: "envelope", file: "hagaki_taba.png"},
    {name: "hamster", file: "hamster_sleeping_golden.png"},
    {name: "detective", file: "job_tantei_foreign.png"},
    {name: "flashlight", file: "kaden_kaichu_dentou.png"},
    {name: "singer", file: "music_singer_woman.png"},
    {name: "cactus", file: "plant_saboten1.png"},
    {name: "bag", file: "school_randoseru1_red.png"},
    {name: "skydive", file: "skydiving_woman.png"},
    {name: "badminton", file: "sports_badminton_shuttle.png"},
    {name: "football", file: "sports_ball_amefuto.png"},
    {name: "volleyball", file: "sports_ball_volleyball_blueyellow.png"},
    {name: "climbing", file: "sports_rock_climbing_woman.png"},
    {name: "stopwatch", file: "stopwatch.png"},
    {name: "sushi", file: "sushi_oke_nigiri.png"},
    {name: "surfboard", file: "swimming_surf_board.png"},
    {name: "shoes", file: "tozan_kutsu.png"},
    {name: "shallots", file: "vegetable_negi.png"},
    {name: "pepper", file: "vegetable_paprika_yellow.png"},
    {name: "watch", file: "watch_face_man.png"}
];

//WordsJA 會慢慢減少 移除已經顯示過的單字
async function StartAutoChangeWords(WordsJA) {
    if (cPageId !== 2) return;//如果離開訓練畫面 停止顯示
    //View
    let pWord = GetEID("pWord");
    let imgWord = GetEID("imgWord");
    //亂數選擇位置 & 取得名稱
    let maxNum = WordsJA.length;
    let pos = Math.floor(Math.random() * maxNum);
    if (pos === maxNum) pos = maxNum - 1;
    let wordJOB = WordsJA[pos];
    let name = JOBStrGet(wordJOB, "name").toUpperCase();
    //Show Image
    imgWord.src = "/app/image/Page_Train_AITrain/" + JOBStrGet(wordJOB, "file");
    //Show
    for (let cnt = 0; cnt < name.length; cnt++) {
        pWord.innerText = name.charAt(cnt);
        await delay(2000);
        if (cPageId !== 2) return;//如果離開訓練畫面 停止顯示
    }
    //Remove item
    WordsJA.splice(pos, 1);
    //Next
    setTimeout(() => {
        StartAutoChangeWords(WordsJA);
    }, 0);
}

//Bluetooth=============================================================================================================
let isTraining = false;
let startTrainM;//開始訓練的時間
let CPrism = 0;//當前稜鏡量

function Get_RealTimeInfoEx(Res, MsgJOB) {
    if (!canReceiveBTMsg) return;//阻斷訊息
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
            if (Training && !isTraining) {//訓練開始
                StartAutoChangeWords(WordsJA).then();//呼叫顯示圖檔 & 單字
                startTrainM = GetCurrentM();
                isTraining = Training;
                $("#divRun").fadeIn(500);
            } else if (!Training && isTraining) {//訓練結束
                isTraining = Training;
                $("#divRun").fadeOut(300);
                //紀錄本次訓練內容
                Set_RecordTrain(true);
            }
        }
    }
}


//Network===============================================================================================================
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
            ShowTrainingEnd();
        }, ResCode === "1" ? 0 : 2500)
    }, "Set_RecordTrain", SendJOB, {}, (ResCode, ResMsg) => {
        SAlert("紀錄失敗", ResMsg);
        setTimeout(() => {
            ShowTrainingEnd();
        }, 2500);
    });
}

//提示訓練結束
function ShowTrainingEnd() {
    SAsk("檢測已結束", "", {Confirm: "回首頁", ShowCancel: false}).then(() => {
        top.GoPage("Page_Home");
    });
}