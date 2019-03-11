$(document).ready(function () {
    $.get("https://blog.moonlightming.top/dig",
        {
            "url": get_url(),
            "refer": get_refer(),
            "ua": get_user_agent(),
        }
    )
});

function get_url() {
    return window.location.href;
}

function get_refer() {
    return document.referrer;
}

function get_user_agent() {
    return navigator.userAgent;
}