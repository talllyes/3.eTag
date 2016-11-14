app.controller('eTagTravelTime', function ($scope, $http, $routeParams, $timeout, NgMap, $q, $rootScope) {
    var eTagTravelTime = this;
    var canceller = $q.defer();                                         //宣告ajax控制元件
    $rootScope.canceller = canceller;                                   //將本頁ajax控制元件給全域
    eTagTravelTime.mapCenter = "22.624133,120.269429";                  //地圖初始位置
    eTagTravelTime.mapZoom = 16;                                        //地圖初始縮放
    eTagTravelTime.chooseTabs = "報表清單";                             //當前選擇的標籤
    eTagTravelTime.searchBtnFlag = false;                               //搜尋按紐不可按
    eTagTravelTime.buttonText = "產生報表";                             //搜尋按紐文字
    eTagTravelTime.report = [];                                         //報表清單偵測用
    eTagTravelTime.myPage = new kaiSearch({                             //宣告分頁元件
        controllerScope: $scope,
        controllerName: 'eTagTravelTime.myPage',
        maxSize: 5,
        itemsPerPage: 10,
        watch: ["searchKey"],
    });
    eTagTravelTime.search = {                                           //搜尋條件
        "startDate": getYyyNowDate(),
        "endDate": getYyyNowDate(),
        "roadData": []
    }

    eTagTravelTime.roadData = [
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
        eTagTravelTime.map = map;
    });

    //取得指定路段的座標
    $http({
        method: 'GET',
        url: "api/eTagTravelTime/eTag基本資料"
    }).then(function successCallback(response) {
        angular.forEach(eTagTravelTime.roadData, function (temp1, key) {
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
            url: "api/GetReport/分時旅行時間查詢"
        }).then(function successCallback(response) {
            eTagTravelTime.myPage.setData(response.data);
            eTagTravelTime.report = response.data;
            $(".showLoader").css("display", "none");
            $(".showETagData").css("display", "");
            $(".showETagData").animate({ opacity: 1 }, 1000);
            $timeout.cancel(eTagTravelTime.timeReport);
            eTagTravelTime.timeReport = $timeout(reloadReport, 10000);
            $timeout.cancel(eTagTravelTime.waitSomeTime);
            eTagTravelTime.waitSomeTime = $timeout(waitSomeTime, 5000);
        }, function errorCallback(response) {
        });
    }
    getReport();

    //如果頁面有處理中就定時更新
    function reloadReport() {
        var flag = false;
        angular.forEach(eTagTravelTime.report, function (value, key) {
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
        eTagTravelTime.searchBtnFlag = false;
        eTagTravelTime.buttonText = "產生報表";
    }

    //產生報表
    eTagTravelTime.createReport = function () {
        canceller.resolve();
        var hasChoose = false;
        //檢查選擇至少一個路段
        for (var i = 0; i < eTagTravelTime.roadData.length; i++) {
            if (eTagTravelTime.roadData[i].choose) {
                hasChoose = true;
            }
        }
        if (hasChoose) {
            eTagTravelTime.searchBtnFlag = true;
            eTagTravelTime.buttonText = "傳輸中‧‧‧";
            var roadDataTemp = [];
            angular.forEach(eTagTravelTime.roadData, function (value, key) {
                if (value.choose) {
                    roadDataTemp.push(value);
                }
            });
            eTagTravelTime.search.roadData = roadDataTemp;
            eTagTravelTime.search.notDateList = eTagTravelTime.notDateList;
            $http({
                method: 'POST',
                url: "api/eTagTravelTime/處理分時旅行時間資料",
                data: eTagTravelTime.search
            }).then(function successCallback(response) {
                console.log(response)
                if (response.data != "no") {
                    getReport();
                    eTagTravelTime.search.reportid = response.data;
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
    }

    //開始產生報表內容(這邊射後不理)
    function getETagTrave() {
        $http({
            method: 'POST',
            url: "api/eTagTravelTime/分時旅行時間資料",
            data: eTagTravelTime.search
        }).success(function (data, status, headers, config) {
        }).error(function (data, status, headers, config) {
        });
    }

    //點擊路段checkbox
    eTagTravelTime.eTagCheckBoxClick = function (mapMakers) {
        mapMakers.choose = !mapMakers.choose;
    };

    eTagTravelTime.reset = function () {
        eTagTravelTime.search = {
            "startDate": getYyyNowDate(),
            "endDate": getYyyNowDate(),
            "roadData": []
        }
        angular.forEach(eTagTravelTime.roadData, function (value, key) {
            value.choose = false;
        });
    }

    //點擊出現日期
    eTagTravelTime.dateClick = function (id) {
        $('#searchStartDate').datetimepicker('show');
    }
})