$(document).ready(function () {
    console.log("hellofwkefjwpefjpwe");
    var lock = false;
    $.get("打点服务器的地址",
        {
            "time": gettime(),
            "ip": getip(),
        }, function () {
            lock = true;
        })

});