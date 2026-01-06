window.onload = function () {
    InitBaseInfo().finally(() => {
        setTimeout(function () {
            if (isApp()) location.href = "/app/html/Page_Login.html";
            else location.href = "/console";
        }, 1500);
    });
}

//BasicInfo=============================================================================================================
async function InitBaseInfo() {
    SetCookie("netMode", isNetAvailable() ? "Online" : "Offline").then()//紀錄當前運作方式
}