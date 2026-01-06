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
