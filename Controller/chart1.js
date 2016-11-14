app.controller('chart1', function ($scope, $http) {
    var chart1 = this;
    chart1.eTagNum = "";
    chart1.eTagTop = "";
    chart1.chart1Flag = "1";
    chart1.choose1Top = "1";
    chart1.roadName = "";
    chart1.homeDate = getYyyNowDate();
    chart1.dateDis = true;
    chart1.getHome = function () {
        $(".showLoader").css("display", "");
        $(".hideLoader").css("display", "none");
        chart1.dateDis = true;
        $http({
            method: 'POST',
            url: "api/GetETag/chart1",
            data: chart1.homeDate
        }).success(function (data, status, headers, config) {
            $(".showLoader").css("display", "none");
            $(".hideLoader").css("display", "");
            chart1.eTagNum = data;
            chart1.dateDis = false;
            setChart(chart1.eTagNum.HomeChart1, chart1.eTagNum.road1, chart1.eTagNum.road2, chart1.eTagNum.road3, chart1.eTagNum.road4);
        }).error(function (data, status, headers, config) {
            alert("無法讀取eTag資料，請聯絡資訊室。");
        });
    }
    chart1.getHome();
    chart1.chooseChart = function (type) {
        if (type == "1") {
            chart1.chart1Flag = "1";
            setChart(chart1.eTagNum.HomeChart1, chart1.eTagNum.road1, chart1.eTagNum.road2, chart1.eTagNum.road3, chart1.eTagNum.road4);
        } else {
            chart1.chart1Flag = "2";
            setChart(chart1.eTagNum.HomeChart2, chart1.eTagNum.road1, chart1.eTagNum.road2, chart1.eTagNum.road3, chart1.eTagNum.road4);
        }
    }
    chart1.chooseTop = function (type) {
        if (type == "1") {
            chart1.choose1Top = "1";
        } else {
            chart1.choose1Top = "2";
        }
    }


    function setChart(data, data2, data3, data4, data5) {
        var NowDate = new Date();
        var h = NowDate.getHours();
        if (getYyyNowDate() != chart1.homeDate) {
            h = 24;
        }
        var d1 = [];
        var d2 = [];
        var d3 = [];
        var d4 = [];
        var d5 = [];
        var d6 = [];
        var d7 = [];
        angular.forEach(data, function (value, key) {
            if (key < h) {
                d1.push(value.ComeNums);
            }
        });
        angular.forEach(data, function (value, key) {
            if (key < h) {
                d2.push(value.LeaveNums);
            }
        });
        angular.forEach(data, function (value, key) {
            if (key < h) {
                d3.push(value.StopNums);
            }
        });
        angular.forEach(data2, function (value, key) {
            if (key < h) {
                d4.push(value[0].Avg);
            }
        });
        angular.forEach(data3, function (value, key) {
            if (key < h) {
                d5.push(value[0].Avg);
            }
        });
        angular.forEach(data4, function (value, key) {
            if (key < h) {
                d6.push(value[0].Avg);
            }
        });
        angular.forEach(data5, function (value, key) {
            if (key < h) {
                d7.push(value[0].Avg);
            }
        });


        var tempHour = [];
        for (var i = 0; i < h; i++) {
            tempHour.push(data2[i][0].Hour);
        }
        $('#middleChart').highcharts({
            chart: {
                zoomType: 'xy'
            },
            title: {
                text: '',
                x: -20 //center
            },
            xAxis: {
                categories: tempHour
            },
            yAxis: [{
                title: {
                    text: '流量'
                }, labels: {
                    format: '{value} 輛'
                }
            }, { // Secondary yAxis
                title: {
                    text: '時間'
                },
                labels: {
                    format: '{value} 秒'
                },
                opposite: true
            }], tooltip: {
                shared: true
            },
            legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'top',
                backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
            },
            series: [{
                name: '進入',
                type: 'line',
                data: d1
            }, {
                name: '離開',
                type: 'line',
                data: d2
            }, {
                name: '滯留',
                type: 'line',
                data: d3
            }, {
                name: '路段2-臨海二路(西向)',
                type: 'spline',
                yAxis: 1,
                data: d4,
                tooltip: {
                    valueSuffix: '秒'
                }
            }, {
                name: '路段3-臨海二路(東向)',
                type: 'spline',
                yAxis: 1,
                data: d5,
                tooltip: {
                    valueSuffix: '秒'
                }
            }, {
                name: '路段4-鼓山臨海(西向)',
                type: 'spline',
                yAxis: 1,
                data: d6,
                tooltip: {
                    valueSuffix: '秒'
                }
            }, {
                name: '路段5-臨海鼓山(西向)',
                type: 'spline',
                yAxis: 1,
                data: d7,
                tooltip: {
                    valueSuffix: '秒'
                }
            }]
        });
    }
})

