//西元轉民國年，格式yyyy-mm-dd
function yyyyToYyy(date) {
    if (typeof (date) == "string") {
        var year;
        var tDate;
        try {
            year = parseInt(date.split('-')[0]) + 1911;
            tDate = year + "-" + date.split('-')[1] + "-" + date.split('-')[2];
        }
        catch (err) {
            return "1-01-01";
        }
        return tDate;
    } else {
        return "1-01-01";
    }
}
//民國年轉西元年，格式yyy-mm-dd
function yyyToYyyy(date) {
    if (typeof (date) == "string") {
        try {
            var year = parseInt(date.split('-')[0]) - 1911;
            var tDate = year + "-" + date.split('-')[1] + "-" + date.split('-')[2];
            return tDate;
        }
        catch (err) {
            return "1899-01-01";
        }
    } else {
        return "1899-01-01";
    }
}
//取得今天日期(民國年)，格式yyy-mm-dd
function getYyyNowDate() {
    var Today = new Date();
    var year = Today.getFullYear() - 1911;
    var month = (Today.getMonth() + 1) + "";
    var day = Today.getDate() + "";
    if (month.length == 1) {
        month = "0" + month;
    }
    if (day.length == 1) {
        day = "0" + day;
    }
    return year + "-" + month + "-" + day;
}
//取得昨天日期(民國年)，格式yyy-mm-dd
function getYyyBeforeDate() {
    var Today = new Date();
    Today.setDate(Today.getDate() -1)
    var year = Today.getFullYear() - 1911;
    var month = (Today.getMonth() + 1) + "";
    var day = Today.getDate() + "";
    if (month.length == 1) {
        month = "0" + month;
    }
    if (day.length == 1) {
        day = "0" + day;
    }
    return year + "-" + month + "-" + day;
}
//民國字串轉日期格式，格式yyy-mm-dd
function yyyToDateTime(date) {
    if (typeof (date) == "string") {
        try {
            var year = parseInt(date.split('-')[0]) + 1911;
            var tDate = new Date(year, date.split('-')[1], date.split('-')[2]);
            return tDate;
        }
        catch (err) {
            return new Date(1899,1,1);
        }    
    } else {
        return new Date(1899, 1, 1);
    }
}


//日期格式轉民國年
function getDateChangeYyy(d) {
    var Today = new Date(d);
    var year = Today.getFullYear() - 1911;
    var month = (Today.getMonth() + 1) + "";
    var day = Today.getDate() + "";
    return year + "-" + month + "-" + day;
}