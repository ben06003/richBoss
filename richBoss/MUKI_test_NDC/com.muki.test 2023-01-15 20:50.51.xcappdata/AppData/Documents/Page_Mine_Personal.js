window.onload = function () {
    top.SetHeaderInfo("個人資料", () => {
        top.GoPage("Page_Mine");
    });
    //Fetch
    Get_MemberInfo();
}

//View
function ShowMemberInfo(InfoJOB) {
    GetEID("pName").innerText = JOBStrGet(InfoJOB, "Name");
    GetEID("pMail").innerText = JOBStrGet(InfoJOB, "Email");
    GetEID("inName").value = JOBStrGet(InfoJOB, "Name");
    GetEID("inPhone").value = JOBStrGet(InfoJOB, "Phone");
    GetEID("inBirth").value = JOBStrGet(InfoJOB, "Birth");
    GetEID("pRTime").innerText = GetDate(JOBStrGet(InfoJOB, "RTime"));
    //Photo
    let Photo = JOBStrGet(InfoJOB, "Photo");
    if (Photo.length > 0) GetEID("imgHead").src = Photo;
}

//Network===============================================================================================================
function Get_MemberInfo() {
    let SendJOB = {};
    SFetchClient(function (ResJOB) {
        let ResCode = JOBStrGet(ResJOB, "ResCode");
        let ResMsg = JOBStrGet(ResJOB, "ResMsg");
        if (ResCode === "1") {//Success
            ShowMemberInfo(ResJOB["InfoJOB"]);
        } else if (ResCode === "2") {
            SAlert("查無此會員");
        } else {
            SAlert("未知的回應", "ResCode:" + ResCode + " ResMsg:" + ResMsg);
        }
    }, "Get_MemberInfo", SendJOB);
}

function Set_MemberInfo() {
    //Read
    let name = GetEID("inName").value;
    let phone = GetEID("inPhone").value;
    let birth = GetEID("inBirth").value;
    //Check
    if (name.length === 0) {
        SAlert("姓名不能空白");
        return;
    }
    SAsk("確認要更新您的個人資訊?").then(function (result) {
        if (result.isConfirmed) {
            let SendJOB = {
                name: name,
                phone: phone,
                birth: birth
            };
            SFetchClient(async function (ResJOB) {
                let ResCode = JOBStrGet(ResJOB, "ResCode");
                let ResMsg = JOBStrGet(ResJOB, "ResMsg");
                if (ResCode === "1") {//Success
                    SAsk("更新完成", "", {ShowCancel: false}).then(() => {
                            top.GoPage("Page_Mine")
                        }
                    )
                } else if (ResCode === "2") {
                    SAlert("更新失敗", ResMsg);
                } else {
                    SAlert("未知的回應", "ResCode:" + ResCode + " ResMsg:" + ResMsg);
                }
            }, "Set_MemberInfo", SendJOB);
        }
    })

}