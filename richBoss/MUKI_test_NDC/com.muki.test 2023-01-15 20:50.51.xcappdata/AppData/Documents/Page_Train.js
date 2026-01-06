window.onload = function () {
    //View
    CallAppFunc("setOrientation", "portrait");//設為直立模式
    top.SetHeaderInfo("訓練", null, 1);
    top.SetFooterShow(true);
}

async function GoPageHandler(pageId) {
    let connected = await isDeviceConnected();
    if (!connected) {
        SAsk("請先連接裝置", "需要立即前往搜尋裝置嗎?").then(result => {
            if (result.isConfirmed) {
                top.location.href = "/app/html/Page_Connect.html?From=Home";//前往連接裝置
            }
        });
        return;
    }
    let name = "";
    let head = "Page_Train_";
    let page = "";
    let query = "";
    switch (pageId) {
        case 1:
            name = "智慧訓練";
            page = "Smart";
            query = "next=AITrain";//自動檢測後 前往訓練
            break;
        case 2:
            name = "闖關訓練";
            page = "Level";
            break;
        case 3:
            name = "智慧檢測";
            page = "Smart";
            query = "next=Smart";//自動檢測後 返回訓練清單
            break;
        case 4:
            name = "趣味遊戲";
            page = "Game";
            break;
    }
    if (page.length > 0) {
        //先設定好返回功能 & 樣式
        top.SetHeaderInfo(name, () => {
            top.GoPage("Page_Train");
            StopTrain();//停止只當前的訓練
        }, 2)
        top.SetFooterShow(false);
        top.GoPage(head + page, query);
    }
}