//View
let divItemTmp;

window.onload = function () {
    top.SetHeaderInfo("我的");//Show
    top.SetFooterShow(true);
    //Func
    FirebaseInit();
    //View
    divItemTmp = GetEID("divItem");
    //Show
    ShowItemList();
}


//ItemList
let itemListAry = [
    {name: "個人資料", goPage: "/app/html/Page_Mine_Personal.html", img: "/app/image/Page_Mine/ic_mine_personal.png"},
    {name: "系統資訊", goPage: "/app/html/Page_Mine_System.html", img: "/app/image/Page_Mine/ic_mine_system.png"},
    {name: "隱私政策", goPage: "/app/html/Page_Mine_Privacy.html", img: "/app/image/Page_Mine/ic_mine_privacy.png"},
    {
        name: "實驗功能",
        goPage: "/app/html/Page_Mine_Exp.html",
        img: "/app/image/Page_Mine/ic_mine_science.png",
        showJA: ["exp", "dev"]
    },
    {
        name: "工程工具",
        goPage: "/app/html/Page_Mine_Develop.html",
        img: "/app/image/Page_Mine/ic_mine_develop.png",
        showJA: ["dev"]
    }
];

async function ShowItemList() {
    let exp = await GetCookie("Experiment") === "T";
    let dev = await GetCookie("Develop") === "T";
    let divItemList = GetEID("divItemList");
    divItemList.innerHTML = null;
    for (let cnt = 0; cnt < itemListAry.length; cnt++) {
        let itemJOB = itemListAry[cnt];
        let divItem = CloneEl(divItemTmp);
        let showJA = itemJOB["showJA"];
        let show = false;
        if (showJA == null) show = true;
        else if (exp && showJA.includes("exp")) show = true;
        else if (dev && showJA.includes("dev")) show = true;
        if (!show) continue;
        //Show
        GetEID("imgIcon", divItem).src = JOBStrGet(itemJOB, "img");
        GetEID("pTitle", divItem).innerText = JOBStrGet(itemJOB, "name");
        divItem.addEventListener("click", function () {
            let goPage = JOBStrGet(itemJOB, "goPage");
            top.iframeHref(goPage).then();
        });
        divItemList.appendChild(divItem);
    }
}

//logout
function logout() {
    SAsk("確認要登出嗎?", "登出後您將無法繼續訓練",
        {
            Confirm: "登出",
            Cancel: "取消",
            ShowCancel: true,
            CancelAble: true
        }).then(result => {
        if (result.isConfirmed) {
            CallAppFunc("disConnectDevice");//斷開裝置
            FirebaseSignOut();//登出後前往初始頁面
        }
    });
}