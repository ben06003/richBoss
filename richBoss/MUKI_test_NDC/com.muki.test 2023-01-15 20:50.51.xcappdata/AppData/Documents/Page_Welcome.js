window.onload = async function () {
    //Head
    let imgHead = GetEID("imgHead");
    imgHead.addEventListener("load", function () {
        $("#divMain").fadeIn(300);
    })
    imgHead.src = await GetCookie("photo");
    //Welcome msg
    GetEID("pWelcome").innerText = "Hi! " + await GetCookie("name") + " 歡迎使用";
    //Check device connection
    let connected = await isDeviceConnected();
    if (!connected) {
        let macAddress = await GetCookie("macAddress");
        if (macAddress != null && macAddress.length > 0) {
            GetEID("pHint").innerText = "您的裝置尚未連接，正在嘗試自動連接";
        } else {
            GetEID("pHint").innerText = "您的裝置尚未連接，即將前往連接裝置";
        }
    }
    //Go Page
    setTimeout(function () {
        location.href = "/app/html/Page_" + (connected ? "Main" : "Connect") + ".html";
    }, 1500)
}