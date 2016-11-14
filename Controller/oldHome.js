app.controller('oldHome', function ($scope, $http, $interval, $q, $rootScope, NgMap) {
    var oldHome = this;
    var reloadTime = 60000;               //重讀資料時間
    oldHome.allDayComeleaveNum = [];         //一天進出入統計
    oldHome.searchDate = getYyyBeforeDate();      //取得今天日期(民國年)
    oldHome.eTagCountNum = [];               //一天各eTag統計
    oldHome.eTagCountChart = [];             //統計圖表
    oldHome.zoneChooseFlag = "1";
    oldHome.chartChooseFlag = "1";
    oldHome.search = {
        startDate: getYyyBeforeDate(),     //取得今天日期(民國年)
        endDate: getYyyBeforeDate()
    }
    oldHome.dataComeLeave = [];
    oldHome.mapCenter = "22.624133,120.269429";
    oldHome.mapZoom = 16;
    oldHome.excel = false;
    var canceller = $q.defer();
    $rootScope.canceller = canceller;
    oldHome.getHome = function () {
        $(".allDayComeleaveNumLoader").css("display", "");
        $http({
            method: 'POST',
            url: "api/oldHome/週內日進出入統計",
            data: oldHome.search
        }).success(function (data, status, headers, config) {
            oldHome.dataComeLeave = data;
            oldHome.ComeNum = data.One.ComeNum[0].進入;
            oldHome.LeaveNum = data.One.LeaveNum[0].離開;
            oldHome.StopNum = data.One.StopNum[0].滯留;
            $(".allDayComeleaveNumLoader").css("display", "none");
            oldHome.allDayComeleaveNum = data;
        }).error(function (data, status, headers, config) {
            alert("無法讀取eTag資料，請聯絡資訊室。");
        });
    }
    oldHome.getHome2 = function () {
        $(".eTagCountLoader").css("display", "");
        $(".eTagCountOk").css("display", "none");
        $http({
            method: 'POST',
            url: "api/home/各eTag累積統計",
            data: oldHome.searchDate
        }).success(function (data, status, headers, config) {
            $(".eTagCountLoader").css("display", "none");
            $(".eTagCountOk").css("display", "");
            oldHome.eTagCountNum = data;
        }).error(function (data, status, headers, config) {
            alert("無法讀取eTag資料，請聯絡資訊室。");
        });
    };
    oldHome.getHome3 = function () {
        oldHome.excel = false;
        $(".eTagCountChartLoader").css("display", "");
        $(".eTagCountChartOk").css("display", "none");
        $http({
            method: 'POST',
            url: "api/oldHome/週內日分時流量資料",
            data: oldHome.search
        }).success(function (data, status, headers, config) {
            console.log(data);
            $(".eTagCountChartLoader").css("display", "none");
            $(".eTagCountChartOk").css("display", "");
            oldHome.eTagCountChart = data;
            for (var i = 0; i < 7; i++) {
                if (oldHome.eTagCountChart.HamaxingCount[i][0].has) {
                    setChart(oldHome.eTagCountChart.HamaxingCount[i], oldHome.eTagCountChart.SiziwanCount[i]);
                    oldHome.excel = true;
                    oldHome.chartWeek = i;
                    break;
                }
            }
            ;
        }).error(function (data, status, headers, config) {
            alert("無法讀取eTag資料，請聯絡資訊室。");
        });
    };
    oldHome.getHome();
    oldHome.getHome2();
    oldHome.getHome3();




    //取得地圖
    NgMap.getMap().then(function (map) {
        oldHome.map = map;
    });
    oldHome.eTagMouseover = function (eTagCountNum) {
        $("#homeMap").css("left", "0");
        $("#homeMap").css("position", "");
        $("#middleChart").css("left", "-9999px");
        $("#middleChart").css("position", "absolute");
        if (oldHome.map != null && oldHome.eTagCountNum != null) {
            oldHome.roadName = eTagCountNum.RoadName;
            oldHome.map.setZoom(16);
            oldHome.map.setCenter(oldHome.map.markers[eTagCountNum.DeviceID].getPosition());
            for (var i = 0; i < oldHome.eTagCountNum.length; i++) {
                oldHome.map.markers[oldHome.eTagCountNum[i].DeviceID].setAnimation(null);
            }
            var that = oldHome.map.markers[eTagCountNum.DeviceID];
            that.setAnimation(google.maps.Animation.BOUNCE);
        }
    };
    oldHome.eTagMouseleave = function (eTagCountNum) {
        oldHome.roadName = '';
        $("#middleChart").css("left", "0");
        $("#middleChart").css("position", "");
        $("#homeMap").css("left", "-9999px");
        $("#homeMap").css("position", "absolute");
    }

    oldHome.chooseWeek = function (type) {
        oldHome.chartWeek = type;
        if (oldHome.chartChooseFlag == "1") {
            setChart(oldHome.eTagCountChart.HamaxingCount[type], oldHome.eTagCountChart.SiziwanCount[type]);
        } else {
            setChart(oldHome.eTagCountChart.HamaxingHourCount[type], oldHome.eTagCountChart.SiziwanHourCount[type]);
        }
    }
    oldHome.chooseChart = function (type) {
        if (type == "1") {
            oldHome.chartChooseFlag = "1";
            setChart(oldHome.eTagCountChart.HamaxingCount[oldHome.chartWeek], oldHome.eTagCountChart.SiziwanCount[oldHome.chartWeek]);
        } else {
            oldHome.chartChooseFlag = "2";
            setChart(oldHome.eTagCountChart.HamaxingHourCount[oldHome.chartWeek], oldHome.eTagCountChart.SiziwanHourCount[oldHome.chartWeek]);
        }
    }
    oldHome.chooseZone = function (type) {
        console.log(oldHome.dataComeLeave);
        if (type == "1") {
            oldHome.zoneChooseFlag = "1";

            oldHome.ComeNum = oldHome.dataComeLeave.One.ComeNum[0].進入;
            oldHome.LeaveNum = oldHome.dataComeLeave.One.LeaveNum[0].離開;
            oldHome.StopNum = oldHome.dataComeLeave.One.StopNum[0].滯留;
          
        } else {
            oldHome.zoneChooseFlag = "2";
            oldHome.ComeNum = oldHome.dataComeLeave.Two.ComeNum[0].進入;
            oldHome.LeaveNum = oldHome.dataComeLeave.Two.LeaveNum[0].離開;
            oldHome.StopNum = oldHome.dataComeLeave.Two.StopNum[0].滯留;
        }
    }
    oldHome.reloadDate = function () {
        canceller.resolve();
        oldHome.zoneChooseFlag = "1";
        oldHome.chartChooseFlag = "1";
        oldHome.getHome();
        oldHome.getHome2();
        oldHome.getHome3();
    }
    oldHome.dateClick = function (id) {
        $('#' + id).datetimepicker('show');
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
