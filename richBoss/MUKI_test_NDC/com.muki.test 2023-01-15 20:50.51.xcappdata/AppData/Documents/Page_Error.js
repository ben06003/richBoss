let divErrorTmp;
let isViewLoaded = false;
window.onload = function () {
    //View
    divErrorTmp = GetEID("divError");
    GetEID("divErrorList").innerHTML = null;
    //Request
    isViewLoaded = true;
    CallAppFunc("sendMsg", "Get_RealTimeInfo");//詢問最新錯誤
}

function ClearError() {
    CallAppFunc("sendMsg", "Set_ClearError");//清除錯誤並返回首頁
}

//Bluetooth=============================================================================================================
function JSFuncHandler(Func, Value) {
    if (Func === "BTMsgReceive") {
        if (!isViewLoaded) return;
        BTMsgReceive(Value);
    }
}

function BTMsgReceive(Value) {
    let JOB = GetJOB(Value);
    let Cmd = JOBStrGet(JOB, "Cmd");
    let Res = JOBStrGet(JOB, "Res");
    if (Cmd === "Get_RealTimeInfo") {
        Get_RealTimeInfo(Res, JOBStrGetInit(JOB, "MsgJOB", {}));
    } else if (Cmd === "Set_ClearError") {
        if (Res === "1") history.back();
    }
}

let preErrorMain = "";

function Get_RealTimeInfo(Res, MsgJOB) {
    if (Res === "1") {
        let errorMain = JOBStrGet(MsgJOB, "Error");
        if (errorMain.length > 0) {
            if (errorMain !== preErrorMain) {
                preErrorMain = errorMain;
                //Parse error
                let errorsAry = errorMain.split(',');
                //Show
                let divErrorList = GetEID("divErrorList");
                divErrorList.innerHTML = null;
                for (let cnt = 0; cnt < errorsAry.length; cnt++) {
                    let error = errorsAry[cnt];
                    if (error.length > 0) {
                        let errorMsg = "未知錯誤";
                        switch (error) {
                            case "0":
                                errorMsg = "離開原點超時";
                                break;
                            case "1":
                                errorMsg = "前往原點超時";
                                break;
                            case "2":
                                errorMsg = "L1 儲存零點失敗";
                                break;
                            case "3":
                                errorMsg = "R1 儲存零點失敗";
                                break;
                            case "4":
                                errorMsg = "L2 儲存零點失敗";
                                break;
                            case "5":
                                errorMsg = "R2 儲存零點失敗";
                                break;
                            case "6":
                                errorMsg = "自動計步 未在原點上";
                                break;
                            case "7":
                                errorMsg = "前往零點超時";
                                break;
                        }
                        let divError = CloneEl(divErrorTmp);
                        GetEID("pError", divError).innerText = errorMsg;
                        divErrorList.appendChild(divError);
                    }
                }
                //Show
                let divErrorMain = GetEID("divErrorMain");
                $(divErrorMain).fadeIn(600, function () {
                    ClassRemover(divErrorMain, "hidden");
                });
            }
        } else location.href = "/app/html/Page_Main.html"//BackIndex
    }
}
