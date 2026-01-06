window.onload = function () {
    if (isApp()) {
        Init();
        trainTypeHandler();
    }
}

function trainTypeHandler() {
    let slMode = GetEID("slMode");
    slMode.innerHTML = null;
    optionGenerator(slMode, "基礎訓練 A (4)", "Mode5_A1");
    optionGenerator(slMode, "基礎訓練 B (6)", "Mode5_A2");
    optionGenerator(slMode, "基礎訓練 C (8)", "Mode5_A3");
    optionGenerator(slMode, "基礎訓練 D (10)", "Mode5_A4");
    optionGenerator(slMode, "基礎訓練 E (12)", "Mode5_A5");
    optionGenerator(slMode, "基礎訓練 F (14)", "Mode5_A6");
    optionGenerator(slMode, "基礎訓練 G (16)", "Mode5_A7");
    optionGenerator(slMode, "提升訓練 H (18)", "Mode5_B1");
    optionGenerator(slMode, "提升訓練 I (20)", "Mode5_B2");
    optionGenerator(slMode, "提升訓練 J (22)", "Mode5_B3");
    optionGenerator(slMode, "提升訓練 K (24)", "Mode5_B4");
    optionGenerator(slMode, "進階訓練 L (26)", "Mode5_C1");
    optionGenerator(slMode, "進階訓練 M (28)", "Mode5_C2");
    optionGenerator(slMode, "進階訓練 N (30)", "Mode5_C3");
    optionGenerator(slMode, "進階訓練 O (32)", "Mode5_C4");
}

function optionGenerator(slMode, name, value) {
    let option = document.createElement("option");
    option.innerText = name;
    option.value = value;
    slMode.appendChild(option);
}
