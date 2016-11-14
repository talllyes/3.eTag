app.controller('eTagWeekTravelTime', function ($scope, $http, $routeParams, $timeout, NgMap, $q, $rootScope) {
    var eTagWeekTravelTime = this;
    var canceller = $q.defer();                                         //宣告ajax控制元件
    $rootScope.canceller = canceller;                                   //將本頁ajax控制元件給全域
    eTagWeekTravelTime.mapCenter = "22.624133,120.269429";              //地圖初始位置
    eTagWeekTravelTime.mapZoom = 16;                                    //地圖初始縮放
    eTagWeekTravelTime.chooseTabs = "報表清單";                         //當前選擇的標籤
    eTagWeekTravelTime.chooseSearchTabs = "搜尋項目"                    //當前選擇的標籤
    var notDateListID = 0;                                              //排除日期id當index用
    eTagWeekTravelTime.searchBtnFlag = false;                           //搜尋按紐不可按
    eTagWeekTravelTime.buttonText = "產生報表";                         //搜尋按紐文字
    eTagWeekTravelTime.notDateList = [];                                //排除日期
    eTagWeekTravelTime.report = [];                                     //報表清單偵測用
    eTagWeekTravelTime.myPage = new kaiSearch({                         //宣告分頁元件
        controllerScope: $scope,
        controllerName: 'eTagWeekTravelTime.myPage',
        maxSize: 5,
        itemsPerPage: 10,
        watch: ["searchKey"],
    });
    eTagWeekTravelTime.search = {                                       //搜尋條件
        "startDate": getYyyNowDate(),
        "endDate": getYyyNowDate(),
        "roadData": []
    }
    eTagWeekTravelTime.roadData = [                                     //路段,這邊先用直接打的
       {
           "startID": "1005",
           "endID": "1006",
           "distance": 2300,
           "roadName": "路段1-中正路",
           "startPx": null,
           "startPy": null,
           "endPx": null,
           "endPy": null,
           "Max": 13.8,
           "Min": 1.97,
           "choose": false
       }, {
           "startID": "1001",
           "endID": "1007",
           "distance": 650,
           "roadName": "路段2-臨海二路(西向)",
           "startPx": null,
           "startPy": null,
           "endPx": null,
           "endPy": null,
           "Max": 3.9,
           "Min": 0.56,
           "choose": false
       }, {
           "startID": "1008",
           "endID": "1002",
           "distance": 650,
           "roadName": "路段3-臨海二路(東向)",
           "startPx": null,
           "startPy": null,
           "endPx": null,
           "endPy": null,
           "Max": 3.9,
           "Min": 0.56,
           "choose": false
       }, {
           "startID": "1003",
           "endID": "1007",
           "distance": 1100,
           "roadName": "路段4-鼓山臨海(西向)",
           "startPx": null,
           "startPy": null,
           "endPx": null,
           "endPy": null,
           "Max": 6.6,
           "Min": 0.94,
           "choose": false
       }, {
           "startID": "1008",
           "endID": "1004",
           "distance": 1100,
           "roadName": "路段5-臨海鼓山(西向)",
           "startPx": null,
           "startPy": null,
           "endPx": null,
           "endPy": null,
           "Max": 6.6,
           "Min": 0.94,
           "choose": false
       }, {
           "startID": "0003",
           "endID": "0004",
           "distance": 777,
           "roadName": "路段6-五福四路(西向)",
           "startPx": null,
           "startPy": null,
           "endPx": null,
           "endPy": null,
           "Max": 4.66,
           "Min": 0.67,
           "choose": false
       }, {
           "startID": "0006",
           "endID": "0005",
           "distance": 1719,
           "roadName": "路段7-建國路(東向)",
           "startPx": null,
           "startPy": null,
           "endPx": null,
           "endPy": null,
           "Max": 10.31,
           "Min": 1.47,
           "choose": false
       }, {
           "startID": "0001",
           "endID": "0008",
           "distance": 4269,
           "roadName": "路段8-中山沿海路(南向)",
           "startPx": null,
           "startPy": null,
           "endPx": null,
           "endPy": null,
           "Max": 25.78,
           "Min": 3.22,
           "choose": false
       }, {
           "startID": "0007",
           "endID": "0002",
           "distance": 4269,
           "roadName": "路段9-中山沿海路(北向)",
           "startPx": null,
           "startPy": null,
           "endPx": null,
           "endPy": null,
           "Max": 25.78,
           "Min": 3.22,
           "choose": false
       }
    ]

    //取得地圖
    NgMap.getMap().then(function (map) {
        eTagWeekTravelTime.map = map;
    });

    //取得指定路段的座標
    $http({
        method: 'GET',
        url: "api/eTagTravelTime/eTag基本資料"
    }).then(function successCallback(response) {
        angular.forEach(eTagWeekTravelTime.roadData, function (temp1, key) {
            angular.forEach(response.data, function (temp2, key) {
                if (temp1.startID == temp2.id) {
                    temp1.startPx = temp2.px;
                    temp1.startPy = temp2.py;
                }
                if (temp1.endID == temp2.id) {
                    temp1.endPx = temp2.px;
                    temp1.endPy = temp2.py;
                }
            });
        });
    }, function errorCallback(response) {
    });

    //取得報表清單
    function getReport() {
        $http({
            method: 'GET',
            url: "api/GetReport/多週內日分時旅行時間"
        }).then(function successCallback(response) {
            eTagWeekTravelTime.myPage.setData(response.data);
            eTagWeekTravelTime.report=response.data;
            $(".showLoader").css("display", "none");
            $(".showETagData").css("display", "");
            $(".showETagData").animate({ opacity: 1 }, 1000);
            $timeout.cancel(eTagWeekTravelTime.timeReport);
            eTagWeekTravelTime.timeReport = $timeout(reloadReport, 10000);
            $timeout.cancel(eTagWeekTravelTime.waitSomeTime);
            eTagWeekTravelTime.waitSomeTime = $timeout(waitSomeTime, 5000);
        }, function errorCallback(response) {
        });
    }
    getReport();

    //如果頁面有處理中就定時更新
    function reloadReport() {
        var flag = false;
        angular.forEach(eTagWeekTravelTime.report, function (value, key) {
            if (value.Context == null) {
                flag = true;
            }
        });
        if (flag) {
            getReport();
        }
    }

    //等待一些時間
    function waitSomeTime() {
        eTagWeekTravelTime.searchBtnFlag = false;                           
        eTagWeekTravelTime.buttonText = "產生報表";                    
    }

    //產生報表
    eTagWeekTravelTime.createReport = function () {
        if (eTagWeekTravelTime.search.startDate <= eTagWeekTravelTime.search.endDate) {
            canceller.resolve();
            var hasChoose = false;
            //檢查選擇至少一個路段
            for (var i = 0; i < eTagWeekTravelTime.roadData.length; i++) {
                if (eTagWeekTravelTime.roadData[i].choose) {
                    hasChoose = true;
                }
            }
            if (hasChoose) {
                eTagWeekTravelTime.searchBtnFlag = true;                          
                eTagWeekTravelTime.buttonText = "傳輸中‧‧‧";                    
                var roadDataTemp = [];
                angular.forEach(eTagWeekTravelTime.roadData, function (value, key) {
                    if (value.choose) {
                        roadDataTemp.push(value);
                    }
                });
                eTagWeekTravelTime.search.roadData = roadDataTemp;
                eTagWeekTravelTime.search.notDateList = eTagWeekTravelTime.notDateList;
                $http({
                    method: 'POST',
                    url: "api/eTagWeekTravelTime/處理週內日分時旅行時間資料",
                    data: eTagWeekTravelTime.search
                }).then(function successCallback(response) {
                    if (response.data != "no") {
                        getReport();
                        eTagWeekTravelTime.search.reportid = response.data;
                        getETagTrave();
                    } else {
                        alert("處理中的報表不可超過3個，請等待完成後再試。");
                        waitSomeTime();
                    }
                }, function errorCallback(response) {
                });
            } else {
                alert("請至少選擇一個路段");
            }
        } else {
            alert('開始日期大於結束日期請重新選擇。');
        }
    }

    //開始產生報表內容(這邊射後不理)
    function getETagTrave() {
        $http({
            method: 'POST',
            url: "api/eTagWeekTravelTime/週內日分時旅行時間資料",
            data: eTagWeekTravelTime.search
        }).success(function (data, status, headers, config) {
        }).error(function (data, status, headers, config) {
        });
    }

    //點擊路段checkbox
    eTagWeekTravelTime.eTagCheckBoxClick = function (roadData) {
        angular.forEach(eTagWeekTravelTime.roadData, function (value, key) {
            value.choose = false;
        });
        roadData.choose = !roadData.choose;
    };

    //顯示日曆介面
    eTagWeekTravelTime.dateClick = function (id) {
        $('#' + id).datetimepicker('show');
    }

    //按下重置
    eTagWeekTravelTime.reset = function () {
        eTagWeekTravelTime.search = {
            "startDate": getYyyNowDate(),
            "endDate": getYyyNowDate(),
            "roadData": []
        }
        angular.forEach(eTagWeekTravelTime.roadData, function (value, key) {
            value.choose = false;
        });
        eTagWeekTravelTime.notDateList = [];
        $timeout(changeDateColor, 10);
    }


    //以下為排除日期程式

    //清除日曆上的active之class
    $(".datetimepicker-days tbody td").removeClass("active");

    //選擇日歷上的日期之監聽事件
    $('#notSearchDate').datetimepicker().on('changeDate', function (ev) {
        var flag = true;
        angular.forEach(eTagWeekTravelTime.notDateList, function (value, key) {
            if (value.date == getDateChangeYyy(ev.date)) {
                flag = false;
            }
        });
        if (flag) {
            var temp = {
                id: notDateListID,
                date: getDateChangeYyy(ev.date)
            }
            eTagWeekTravelTime.notDateList.push(temp);
            notDateListID = notDateListID + 1;
        } else {
            angular.forEach(eTagWeekTravelTime.notDateList, function (value, key) {
                if (value.date == getDateChangeYyy(ev.date)) {
                    eTagWeekTravelTime.notDateList.splice(key, 1);
                }
            });
        }
        $timeout(changeDateColor, 10);
    });

    //點擊日曆的監聽事件
    $(".datetimepicker-days").on('click', function (ev) {
        $timeout(changeDateColor, 10);
    });

    //改變日期的月監聽事件
    $('#notSearchDate').datetimepicker().on('changeMonth', function (ev) {
        $timeout(changeDateColor, 10);
    });

    //改變日期的年監聽事件
    $('#notSearchDate').datetimepicker().on('changeYear', function (ev) {
        $timeout(changeDateColor, 10);
    });

    //將選到的日期增加active的class
    function changeDateColor() {
        $(".datetimepicker-days tbody td").removeClass("active");
        angular.forEach(eTagWeekTravelTime.notDateList, function (value, key) {
            $("[data-date='" + value.date + "']").addClass("active");
        });
    }
})

