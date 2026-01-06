//WebSocket=============================================================================================================
let SVSoc;
let SVSocReceiveDataHandler;//用於統一接收資訊
let SVWebSocketServerAddress = "ws://" + location.hostname + ":9602";//

//Receive===============================================================================================================
function SVSetReceiveDataHandler(Func) {
    SVSocReceiveDataHandler = Func;
}

//Send==================================================================================================================
//單純送資料過去
function SVSendMsg(ApiName, Msg = "") {
    let SendJOB = {
        ApiName: ApiName,
        Msg: Msg
    };
    //Send
    SVSendData(JSON.stringify(SendJOB));
}

function SVSendData(SendJOBStr) {
    if (isNetAvailable()) {
        SVConnectSocketServer(SVWebSocketServerAddress).then(() => {
            if (SVSoc != null && SVSoc.readyState === 1) {//正常可以連接時
                SVSoc.send(SendJOBStr);
            }
        }).catch(err => {
            Log("[error] " + err.message);
        });
    }
}

function SVConnectSocketServer(TargetAddress) {
    return new Promise((resolve, reject) => {
        if (SVSoc == null || SVSoc.readyState !== 1) {//未正常連接狀態時 開始連結
            try {
                //Close
                if (SVSoc != null) {
                    SVSoc.close();
                    SVSoc = null;
                }
                //Connect
                SVSoc = new WebSocket(TargetAddress);
                SVSoc.onopen = function (event) {
                    Log("[open] Connection established");
                    resolve();
                };

                SVSoc.onmessage = function (event) {
                    if (typeof SVSocReceiveDataHandler == "function") SVSocReceiveDataHandler(event.data);
                };

                SVSoc.onclose = function (event) {
                    if (event.wasClean) {
                        reject("[close] Connection closed cleanly");
                    } else {
                        // 例如服务器进程被杀死或网络中断
                        // 在这种情况下，event.code 通常为 1006
                        reject("[close] Connection died");
                    }
                };

                SVSoc.onerror = function (error) {
                    reject("[error]: " + error.message);
                };
            } catch (e) {
                reject("[error]: " + e.message);
            }
        } else {
            resolve();
        }
    });
}

//Server================================================================================================================
async function SVOpenWebSocketServer() {
    console.log("Checking Server BackgroundServices")
    return new Promise((resolve, reject) => {
        let XHR = new XMLHttpRequest();
        XHR.timeout = 5000; // time in milliseconds
        XHR.onreadystatechange = function () {
            try {
                if (this.readyState === 4) resolve(true);
            } catch (e) {
                reject(e.message);
                console.log(e.stack);
                console.log(this.responseText);
            }
        };
        //Post
        XHR.open("GET", "/webSocket/WebSocketServer.php", true);
        XHR.send(null);
    });
}

function SVCloseWebSocketServer() {
    SVSendData("EXIT");
}

//Common================================================================================================================
function Log(Msg) {
    console.log(Msg);
}
