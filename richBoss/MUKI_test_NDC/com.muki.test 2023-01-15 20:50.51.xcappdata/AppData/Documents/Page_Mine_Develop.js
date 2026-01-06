window.onload = function () {
    top.SetFooterShow(false);
    top.SetHeaderInfo("工程工具", () => {
        top.GoPage("Page_Mine");
    })
}

function GoPage(page, el) {
    //先設定好返回功能
    top.SetHeaderInfo(el.innerText, () => {
        top.GoPage("Page_Mine_Develop");
    })
    top.GoPage(page);
}

