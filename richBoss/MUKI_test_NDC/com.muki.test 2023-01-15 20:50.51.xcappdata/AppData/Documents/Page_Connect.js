let divDeviceTmp;
window.onload = function () {
    //View
    divDeviceTmp = GetEID("divDevice");
    GetEID("divDeviceList").innerHTML = null;
    //Data
    CallAppFunc("disConnectDevice");//斷開裝置
    setTimeout(function () {
        CallAppFunc("startScan");//開始掃描
        AutoFetchDeviceList().then();
    }, 500)
}

async function AutoFetchDeviceList() {
    let deviceMapStr = await CallAppFuncCB("getScanDeviceMap");
    if (typeof deviceMapStr === "string") {
        let deviceMapJOB = JSON.parse(deviceMapStr);
        ShowDeviceList(deviceMapJOB);
    }
    setTimeout(function () {
        AutoFetchDeviceList();
    }, 3000);
}

function ShowDeviceList(deviceMapJOB) {
    //Clear
    let divDeviceList = GetEID("divDeviceList");
    divDeviceList.innerHTML = null;
    //Show
    let keys = Object.keys(deviceMapJOB);
    for (let cnt = 0; cnt < keys.length; cnt++) {
        let macAddress = keys[cnt];
        let valJOB = deviceMapJOB[macAddress]["nameValuePairs"];
        let divDevice = CloneEl(divDeviceTmp);
        let pDeviceId = GetEID("pDeviceId", divDevice);
        let divProgress = GetEID("divProgress", divDevice);
        let btDevice = GetEID("btDevice", divDevice);
        //Device
        pDeviceId.innerText = JOBStrGet(valJOB, "DeviceName");
        btDevice.addEventListener("click", function () {
            SetCookie("macAddress", macAddress).then();
            CallAppFunc("connectDevice", macAddress);
        });
        //Rssi
        let deviceRssi = JOBNumGet(valJOB, "DeviceRssi")
        let rssiPercent = 2 * (deviceRssi + 100);
        if (rssiPercent > 100) {
            rssiPercent = 100;
        } else if (rssiPercent < 0) {
            rssiPercent = 0;
        }
        //Color
        let rssiColorID;
        if (rssiPercent >= 90) {
            rssiColorID = "#80FFB6";
        } else if (rssiPercent > 50) {
            rssiColorID = "#389bff";
        } else if (rssiPercent > 30) {
            rssiColorID = "#FFD685";
        } else {
            rssiColorID = "#F06";
        }
        //Set Color
        //Show
        divDeviceList.appendChild(divDevice);
        //CircleProgress 必須要顯示後才能使用
        $(divProgress).circleProgress({
            min: 0,
            max: 100,
            value: rssiPercent,
            constrain: true,
            textFormat: 'percent',
            animationDuration: 0
        });
        //Set Color
        let Els = divDevice.getElementsByClassName("circle-progress-value");
        if (Els.length > 0) Els[0].style.stroke = rssiColorID;
    }
}
