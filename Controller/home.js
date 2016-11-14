app.controller('home', function ($scope, $http, $interval, $q, $rootScope, NgMap) {
    var home = this;
    var reloadTime = 60000;               //重讀資料時間
    home.allDayComeleaveNum = [];         //一天進出入統計
    home.homeDate = getYyyNowDate();      //取得今天日期(民國年)
    home.eTagCountNum = [];               //一天各eTag統計
    home.eTagCountChart = [];             //統計圖表
    home.zoneChooseFlag = "1";
    home.chartChooseFlag = "1";
    home.mapCenter = "22.624133,120.269429";
    home.mapZoom = 16;
    var canceller = $q.defer();
    $rootScope.canceller = canceller;

    home.getHome = function () {
        $http({
            method: 'POST',
            url: "api/home/進出入統計",
            data: home.homeDate
        }).success(function (data, status, headers, config) {
            $(".allDayComeleaveNumLoader").css("display", "none");
            home.allDayComeleaveNum = data;
        }).error(function (data, status, headers, config) {
            alert("無法讀取eTag資料，請聯絡資訊室。");
        });
    }
    home.getHome2 = function () {
        $http({
            method: 'POST',
            url: "api/home/各eTag累積統計",
            data: home.homeDate
        }).success(function (data, status, headers, config) {
            $(".eTagCountLoader").css("display", "none");
            home.eTagCountNum = data;
        }).error(function (data, status, headers, config) {
            alert("無法讀取eTag資料，請聯絡資訊室。");
        });
    };
    home.getHome3 = function () {
        $http({
            method: 'POST',
            url: "api/home/各小時進出入累積統計",
            data: home.homeDate
        }).success(function (data, status, headers, config) {
            $(".eTagCountChartLoader").css("display", "none");
            $(".eTagCountChartOk").css("display", "");
            home.eTagCountChart = data;
            setChart(home.eTagCountChart.HamaxingCount, home.eTagCountChart.SiziwanCount);
        }).error(function (data, status, headers, config) {
            alert("無法讀取eTag資料，請聯絡資訊室。");
        });
    };
    home.getHome();
    home.getHome2();
    home.getHome3();

    //取得地圖
    NgMap.getMap().then(function (map) {
        home.map = map;
    });
    home.eTagMouseover = function (eTagCountNum) {
        $("#homeMap").css("left", "0");
        $("#homeMap").css("position", "");
        $("#middleChart").css("left", "-9999px");
        $("#middleChart").css("position", "absolute");
        if (home.map != null && home.eTagCountNum != null) {
            home.roadName = eTagCountNum.RoadName;
            home.map.setZoom(16);
            home.map.setCenter(home.map.markers[eTagCountNum.DeviceID].getPosition());
            for (var i = 0; i < home.eTagCountNum.length; i++) {
                home.map.markers[home.eTagCountNum[i].DeviceID].setAnimation(null);
            }
            var that = home.map.markers[eTagCountNum.DeviceID];
            that.setAnimation(google.maps.Animation.BOUNCE);
        }
    };
    home.eTagMouseleave = function (eTagCountNum) {
        home.roadName = '';
        $("#middleChart").css("left", "0");
        $("#middleChart").css("position", "");
        $("#homeMap").css("left", "-9999px");
        $("#homeMap").css("position", "absolute");
    }



    home.chooseChart = function (type) {
        if (type == "1") {
            home.chartChooseFlag = "1";
            setChart(home.eTagCountChart.HamaxingCount, home.eTagCountChart.SiziwanCount);
        } else {
            home.chartChooseFlag = "2";
            setChart(home.eTagCountChart.HamaxingHourCount, home.eTagCountChart.SiziwanHourCount);
        }
    }
    home.chooseZone = function (type) {
        if (type == "1") {
            home.zoneChooseFlag = "1";
        } else {
            home.zoneChooseFlag = "2";
        }
    }
    $rootScope.reHome = $interval(reloadDate, reloadTime);    
    function reloadDate() {
        home.zoneChooseFlag = "1";
        home.chartChooseFlag = "1";
        canceller.resolve();
        home.getHome();
        home.getHome2();
        home.getHome3();
        console.log('儀表版狀態更新');
    }
})

//圖表函式
function setChart(data, data2) {
    var d1 = [];
    var d2 = [];
    var d3 = [];
    var d4 = [];
    var d5 = [];
    var d6 = [];
    angular.forEach(data, function (value, key) {
        d1.push(value.ComeNums);
    });
    angular.forEach(data, function (value, key) {
        d2.push(value.LeaveNums);
    });
    angular.forEach(data, function (value, key) {
        d3.push(value.StopNums);
    });
    angular.forEach(data2, function (value, key) {
        d4.push(value.ComeNums);
    });
    angular.forEach(data2, function (value, key) {
        d5.push(value.LeaveNums);
    });
    angular.forEach(data2, function (value, key) {
        d6.push(value.StopNums);
    });
    var tempHour = [];
    for (var i = 0; i < data.length; i++) {
        tempHour.push(data[i].Hour);
    }
    $('#middleChart').highcharts({
        title: {
            text: '',
            x: -20 //center
        },
        xAxis: {
            categories: tempHour
        },
        yAxis: {
            title: {
                text: '流量'
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        series: [{
            name: '哈瑪星進入',
            data: d1
        }, {
            name: '哈瑪星離開',
            data: d2
        }, {
            name: '哈瑪星滯留',
            data: d3
        }, {
            name: '西子灣進入',
            data: d4
        }, {
            name: '西子灣離開',
            data: d5
        }, {
            name: '西子灣滯留',
            data: d6
        }]
    });
}
