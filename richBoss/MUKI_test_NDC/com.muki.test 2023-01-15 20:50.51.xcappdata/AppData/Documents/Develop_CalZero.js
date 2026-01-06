window.onload = function () {
    if (isApp()) {
        InitFreq();
        InitMPower();
        setInterval(function () {
            Get_MotorInfo();
        }, 1000);
    }
}

function InitFreq() {
    let slFreq = GetEID("slFreq");
    let Freq = 100;
    slFreq.appendChild(CreateOption(1));
    for (let cnt = 0; cnt < 30; cnt++) {
        slFreq.appendChild(CreateOption(Freq));
        Freq += 100;
    }
    slFreq.value = "1000";
}

function InitMPower() {
    let slMPower = GetEID("slMPower");
    for (let cnt = 0; cnt < 256; cnt += 10) {
        slMPower.appendChild(CreateOption(cnt));
    }
    slMPower.appendChild(CreateOption(255));
    slMPower.value = "250";
}

function CreateOption(value) {
    let option = document.createElement("option");
    let valueStr = value.toString();
    option.value = valueStr;
    option.innerText = valueStr;
    return option;
}


function ConfirmSetZero() {
    SAsk("確認將此點設為零點?", "將同時設置4個鏡片").then(function (result) {
        if (result.isConfirmed) Set_CalZeroControl('SetZero');
    })
}

function Set_MoveStepper(CW, MStep) {
    let MotorId = GetEID("slMotorId").value;
    let MPower = GetEID("slMPower").value;
    let Freq = GetEID("slFreq").value;
    //Prepare
    let JOB = {
        MotorId: MotorId,
        CW: CW,
        Freq: Freq,
        MPower: MPower,
        MStep: MStep
    }
    CallAppFunc("sendMsg", "Set_MoveStepper", JSON.stringify(JOB));
}

function Set_CalZeroControl(Point) {
    //Prepare
    let JOB = {
        Point: Point
    }
    CallAppFunc("sendMsg", "Set_CalZeroControl", JSON.stringify(JOB));
}

function Get_MotorInfo() {
    CallAppFunc("sendMsg", "Get_MotorInfo");
}

function BTMsgReceive(Value) {
    let JOB = GetJOB(Value);
    let Cmd = JOBStrGet(JOB, "Cmd");
    let Res = JOBStrGet(JOB, "Res");
    let MsgJOB = JOBStrGetInit(JOB, "MsgJOB", {});
    if (Cmd === "Get_MotorInfo") {
        Get_MotorInfoHandler(Res, MsgJOB);
    }
}

function Get_MotorInfoHandler(Res, MsgJOB) {
    if (Res === "1") {
        //CMotorPWR
        GetEID("pCMotorPWR").innerText = JOBStrGet(MsgJOB, "CMotorPWR");
        //CW
        GetEID("pL1_CW").innerText = JOBStrGet(MsgJOB, "CW_L1");
        GetEID("pR1_CW").innerText = JOBStrGet(MsgJOB, "CW_R1");
        GetEID("pL2_CW").innerText = JOBStrGet(MsgJOB, "CW_L2");
        GetEID("pR2_CW").innerText = JOBStrGet(MsgJOB, "CW_R2");
        //CPos
        GetEID("pL1_CPos").innerText = JOBStrGet(MsgJOB, "CL1_Pos");
        GetEID("pR1_CPos").innerText = JOBStrGet(MsgJOB, "CR1_Pos");
        GetEID("pL2_CPos").innerText = JOBStrGet(MsgJOB, "CL2_Pos");
        GetEID("pR2_CPos").innerText = JOBStrGet(MsgJOB, "CR2_Pos");
        //TPos
        GetEID("pL1_TPos").innerText = JOBStrGet(MsgJOB, "TL1_Pos");
        GetEID("pR1_TPos").innerText = JOBStrGet(MsgJOB, "TR1_Pos");
        GetEID("pL2_TPos").innerText = JOBStrGet(MsgJOB, "TL2_Pos");
        GetEID("pR2_TPos").innerText = JOBStrGet(MsgJOB, "TR2_Pos");
        //SRun
        GetEID("pL1_SRun").innerText = JOBStrGet(MsgJOB, "SRun_L1");
        GetEID("pR1_SRun").innerText = JOBStrGet(MsgJOB, "SRun_R1");
        GetEID("pL2_SRun").innerText = JOBStrGet(MsgJOB, "SRun_L2");
        GetEID("pR2_SRun").innerText = JOBStrGet(MsgJOB, "SRun_R2");
        //Origin
        GetEID("pL1_Ori").innerText = JOBStrGet(MsgJOB, "Ori_L1");
        GetEID("pR1_Ori").innerText = JOBStrGet(MsgJOB, "Ori_R1");
        GetEID("pL2_Ori").innerText = JOBStrGet(MsgJOB, "Ori_L2");
        GetEID("pR2_Ori").innerText = JOBStrGet(MsgJOB, "Ori_R2");
    }
}

