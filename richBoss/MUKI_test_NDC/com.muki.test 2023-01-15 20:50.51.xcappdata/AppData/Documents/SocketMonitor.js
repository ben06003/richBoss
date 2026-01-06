window.onload = function () {
    InitSocketLogService();
}

function InitSocketLogService() {
    SVOpenWebSocketServer().then(res => {
        if (res) {
            console.log("BackgroundServiceListener Started");
            SVSetReceiveDataHandler(function (Data) {
                let ResJOB = JSON.parse(Data);
                let ApiName = JOBStrGet(ResJOB, "ApiName");
                if (ApiName === "Set_Log") {
                    PLog(JOBStrGet(ResJOB, "ResMsg"));
                } else if (ApiName === "Get_ServerLog") {
                    PLog(JOBStrGet(ResJOB, "ResMsg"));
                } else {
                    console.log(Data);
                }
            });
            //自動連接
            SVConnectSocketServer(SVWebSocketServerAddress).then(() => {
                if (SVSoc != null && SVSoc.readyState === 1) {//正常可以連接時
                    //每30秒 Ping 一次 防止被斷線
                    setInterval(function () {
                        SVSendData("Ping");
                    }, 30000);
                }
            }).catch(err => {
                Log("[error] " + err.message);
            });
        }
    }).catch(e => {
        SAlert("開啟SVSocketServer發生錯誤", e);
    });
}

//Log===========================================================================================================
let LogMsgAl = [];

function PLog(Msg) {
    //Push
    LogMsgAl.push(Msg + "\n");
    //Delete
    while (LogMsgAl.length > 50) {
        LogMsgAl.splice(0, 1);
    }
    //Show
    let Content = "";
    for (let cnt = LogMsgAl.length - 1; cnt >= 0; cnt--) {
        Content += LogMsgAl[cnt];
    }
    GetEID("pContent").innerText = Content;
}

function ClearLog() {
    LogMsgAl = [];
    GetEID("pContent").innerText = "";
}
