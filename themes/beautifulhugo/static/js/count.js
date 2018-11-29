$(document).ready(function () {
    $.get("https://blog.moonlightming.top/dig",
        {
            "url": get_url(),
            "rafer": get_refer(),
            "user_agent": get_user_agent(),
            // "cookies": getcookie(),
        })
});

function get_url() {
    return window.location.href;
}

function get_refer() {
    return document.referrer;
}

function get_cookie() {
    return document.cookie;
}

function get_user_agent() {
    return navigator.userAgent;
}