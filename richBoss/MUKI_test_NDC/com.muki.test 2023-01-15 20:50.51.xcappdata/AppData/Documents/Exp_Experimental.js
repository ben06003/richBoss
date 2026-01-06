let divDataTmp;
window.onload = function () {
    if (isApp()) {
        Init();
        InitListView();
    }
}

function InitListView() {
    divDataTmp = GetEID("divData");
    GetEID("divDataList").innerHTML = null;
    GetStorage("ModeJA").then(ModeJA => {
        if (ModeJA != null && ModeJA.length > 0) {
            for (let cnt = 0; cnt < ModeJA.length; cnt++) {
                let DataJA = ModeJA[cnt];
                AddColumn(DataJA[0], DataJA[1], DataJA[2]);
            }
        } else {
            AddColumn();
        }
    }).catch(() => {
        AddColumn();
    });
    GetStorage("Repeat").then(Repeat => {
        if (Repeat != null && Repeat.length > 0) {
            GetEID("inRepeat").value = Repeat;
        }
    });
}

function StartTest() {
    let ModeJASend = [];
    let ModeJASave = [];
    //Read
    let children = GetEID("divDataList").childNodes;
    for (let cnt = 0; cnt < children.length; cnt++) {
        let divData = children.item(cnt);
        if (divData.id === "divData") {
            let Arrive = GetEID("inArrive", divData).value;
            let Direction = GetEID("slDirection", divData).value;
            let Prism = GetEID("inPrism", divData).value;
            let Stay = GetEID("inStay", divData).value;
            //Check
            if (Arrive.length === 0 || Prism.length === 0 || Stay.length === 0) {
                SAlert("請填入完整資訊");
                return;
            } else if (isNaN(Arrive) || isNaN(Prism) || isNaN(Stay)) {
                SAlert("參數必須為數字", "請將非數字字元移除");
                return;
            } else if (Arrive < 0) {
                SAlert("抵達時間必須為正整數");
                return;
            } else if (Stay < 0) {
                SAlert("停留時間必須為正整數");
                return;
            } else if (Prism < 0 || Prism > 32) {
                SAlert("目標稜鏡度範圍錯誤", "必須在 0 ~ 32 之間");
                return;
            }
            //Convert
            let Degree = ConvertToDegree(Prism);
            if (Direction === "BI") {
                Degree *= -1;
                Prism *= -1;
            }
            //Set
            ModeJASend.push([Arrive, Degree, Stay]);
            ModeJASave.push([Arrive, Prism, Stay])
        }
    }
    //Repeat
    let Repeat = GetEID("inRepeat").value;
    //Check
    if (ModeJASend.length === 0) {
        SAlert("沒有指令資料");
        return;
    } else if (ModeJASend.length > 50) {
        SAlert("指令超過大小限制");
        return;
    } else if (isNaN(Repeat)) {
        SAlert("請輸入正確的重複次數");
        return;
    }
    //Save
    SetStorage("Repeat", Repeat).then();
    SetStorage("ModeJA", ModeJASave).then();
    //Prepare
    let JOB = {
        Mode: "G",
        Repeat: Repeat,
        ModeJA: ModeJASend
    }
    CallAppFunc("sendMsg","Set_StartTrainMode", JSON.stringify(JOB));
}

function AddColumn(Arrive = "", Prism = "", Stay = "") {
    let divData = CloneEl(divDataTmp);
    GetEID("inArrive", divData).value = Arrive;
    GetEID("slDirection", divData).value = Prism < 0 ? "BI" : "BO";
    GetEID("inPrism", divData).value = Math.abs(parseFloat(Prism));
    GetEID("inStay", divData).value = Stay;
    let divDataList = GetEID("divDataList");
    divDataList.appendChild(divData);
    $(divData).fadeIn(500);
}

function RemoveColumn(El) {
    $(El).fadeOut(200, function () {
        let divDataList = GetEID("divDataList");
        divDataList.removeChild(El);
    });
}

//Bluetooth=============================================================================================================
let PreCModePos = 0;
let PreDivData;
let BgRanColor = "bg-yellow-600";

function Get_RealTimeInfoEx(Res, MsgJOB) {
    if (Res === "1") {
        let CModePos = JOBNumGet(MsgJOB, "CModePos");
        if (CModePos !== PreCModePos) {
            PreCModePos = CModePos;
            let divDataList = GetEID("divDataList");
            if (PreDivData != null) ClassRemover(PreDivData, BgRanColor);
            let childNodes = divDataList.childNodes;
            if (CModePos <= childNodes.length) {
                let divData = childNodes[CModePos - 1];
                PreDivData = divData;
                ClassAdder(divData, BgRanColor);
            }
        }
    }
}
