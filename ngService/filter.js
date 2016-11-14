//大小車
app.filter('bigOrSmallCar', function () {
    return function (str, key) {
        var temp = str + "";
        temp = temp.substr(5, 1);
        if (temp == "3") {
            return "小型車";
        } else if (temp == "4") {
            return "大型車";
        } else if (temp == "5") {
            return "聯結車";
        }
    }
});
