window.onload = function () {
    if (isApp()) Init();
}


function StartDurabilityTest() {
    //Repeat
    let Repeat = GetEID("inRepeat").value;
    //Check
    if (isNaN(Repeat)) {
        SAlert("請輸入正確的重複次數");
        return;
    }
    //Prepare
    let JOB = {
        Mode: "H",//耐久測試
        Repeat: Repeat,
        ModeJA: ConvertToDegreeJA(ModeH1)//稜鏡度換算為角度
    }
    CallAppFunc("sendMsg", "Set_StartTrainMode", JSON.stringify(JOB));
}
