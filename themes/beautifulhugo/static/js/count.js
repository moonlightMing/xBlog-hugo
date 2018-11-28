$(document).ready(function () {
    console.log("hellofwkefjwpefjpwe")

    $.get("打点服务器的地址",
        {
            "time": gettime(),
            "ip": getip(),
        })

})