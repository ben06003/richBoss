window.onload = function () {
    if (isApp()) {
        Init();
        trainTypeHandler();
    }
}

function trainTypeHandler() {
    let slMode = GetEID("slMode");
    let type = GetEID("slType").value;
    if (type === "1") {//內聚不足視力訓練
        slMode.innerHTML = null;
        optionGenerator(slMode, "基礎訓練 A (4)", "Mode1_A1");
        optionGenerator(slMode, "基礎訓練 B (6)", "Mode1_A2");
        optionGenerator(slMode, "基礎訓練 C (8)", "Mode1_A3");
        optionGenerator(slMode, "基礎訓練 D (10)", "Mode1_A4");
        optionGenerator(slMode, "基礎訓練 E (12)", "Mode1_A5");
        optionGenerator(slMode, "基礎訓練 F (14)", "Mode1_A6");
        optionGenerator(slMode, "基礎訓練 G (16)", "Mode1_A7");
        optionGenerator(slMode, "提升訓練 H (18)", "Mode1_B1");
        optionGenerator(slMode, "提升訓練 I (20)", "Mode1_B2");
        optionGenerator(slMode, "提升訓練 J (22)", "Mode1_B3");
        optionGenerator(slMode, "提升訓練 K (24)", "Mode1_B4");
        optionGenerator(slMode, "進階訓練 L (26)", "Mode1_C1");
        optionGenerator(slMode, "進階訓練 M (28)", "Mode1_C2");
        optionGenerator(slMode, "進階訓練 N (30)", "Mode1_C3");
    } else if (type === "2") {//內聚過度視力訓練
        slMode.innerHTML = null;
    }
}

function optionGenerator(slMode, name, value) {
    let option = document.createElement("option");
    option.innerText = name;
    option.value = value;
    slMode.appendChild(option);
}

function StartTrainFast() {
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
        switch (Mode) {

        }
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
    //Half
    let HalfModeJA = [];
    for (let cnt = 0; cnt < ModeJA.length; cnt++) {
        let ModeData = ModeJA[cnt];
        ModeData[0] = ModeData[0] / 2;
        ModeData[3] = ModeData[3] / 2;
        HalfModeJA.push(ModeData);
    }
    //Convert
    let ConvertModeJA = ConvertToDegreeJA(HalfModeJA);//稜鏡度換算為角度
    //Prepare
    let JOB = {
        Mode: Mode,
        Repeat: Repeat,
        ModeJA: ConvertModeJA
    }
    CallAppFunc("sendMsg", "Set_StartTrainMode", JSON.stringify(JOB));
}
