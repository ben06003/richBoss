function UpdateVal(El, pId) {
    GetEID(pId).innerText = El.value;
}

function Set_PreviewRGBLight() {
    let R = GetEID("inLightR").value;
    let G = GetEID("inLightG").value;
    let B = GetEID("inLightB").value;
    //Prepare
    let JOB = {
        R: R,
        G: G,
        B: B
    }
    CallAppFunc("sendMsg", "Set_PreviewRGBLight", JSON.stringify(JOB));
}
