app.controller('eTagWeekTimeFlow', function ($scope, $http, $routeParams, $timeout, NgMap, $q, $rootScope) {
    var eTagWeekTimeFlow = this;
    eTagWeekTimeFlow.mapCenter = "22.624133,120.269429";                //地圖初始位置
    eTagWeekTimeFlow.mapZoom = 16;                                      //地圖初始大小
    eTagWeekTimeFlow.chooseTabs = "報表清單";                           //當前選擇的標籤
    eTagWeekTimeFlow.chooseSearchTabs = "搜尋項目"                      //當前選擇的標籤
    eTagWeekTimeFlow.chooseTabsFlag = true;                             //記憶用
    eTagWeekTimeFlow.searchBtnFlag = false;                             //搜尋按紐不可按
    eTagWeekTimeFlow.buttonText = "產生報表";                           //按鈕文字
    eTagWeekTimeFlow.notDateList = [];                                  //排除日期
    var notDateListID = 1;                                              //排除日期的id當index用
    eTagWeekTimeFlow.report = [];                                       //報表清單
    eTagWeekTimeFlow.mapStyle = {                                       //地圖先移到螢幕外面
        position: "absolute",
        top: "-9999px"
    }
    eTagWeekTimeFlow.search = {                                         //搜尋條件
        "startDate": getYyyNowDate(),
        "endDate": getYyyNowDate(),
        "eTag": "",
        "order": true,
        "eTagID": ""
    }
    eTagWeekTimeFlow.myPage = new kaiSearch({                           //宣告分頁元件
        controllerScope: $scope,
        controllerName: 'eTagWeekTimeFlow.myPage',
        maxSize: 5,
        itemsPerPage: 10,
        watch: ["searchKey"],
    });
    var canceller = $q.defer();                                         //宣告ajax控制元件
    $rootScope.canceller = canceller;                                   //將本頁ajax控制元件給全域


    //取得地圖
    NgMap.getMap().then(function (map) {
        eTagWeekTimeFlow.map = map;
    });

    //取得ETag基本資料
    $http({
        method: 'GET',
        url: "api/baseETagDateSearch/取得eTag基本資料"
    }).then(function successCallback(response) {
        eTagWeekTimeFlow.mapMakers = response.data;
    }, function errorCallback(response) {
    });


    //取得報表清單
    function getReport() {
        $http({
            method: 'GET',
            url: "api/GetReport/週內日分時流量資料"
        }).success(function (data, status, headers, config) {
            eTagWeekTimeFlow.myPage.setData(data);
            eTagWeekTimeFlow.report = data;
            $(".showETagData").css("display", "");
            $(".showETagData").animate({ opacity: 1 }, 1000);
            $(".showLoader").css("display", "none");
            $timeout.cancel(eTagWeekTimeFlow.timeReport);
            eTagWeekTimeFlow.timeReport = $timeout(reloadReport, 10000);
            $timeout.cancel(eTagWeekTimeFlow.waitSomeTime);
            eTagWeekTimeFlow.waitSomeTime = $timeout(waitSomeTime, 5000);
        }).error(function (data, status, headers, config) {
        });
    }
    getReport();

    //等待一段時間後才能再次產生報表
    function waitSomeTime() {
        eTagWeekTimeFlow.searchBtnFlag = false;
        eTagWeekTimeFlow.buttonText = "產生報表";
    }
    
    //當頁面上還有處理中的資料時會定時更新
    function reloadReport() {
        var flag = false;
        angular.forEach(eTagWeekTimeFlow.report, function (value, key) {
            if (value.Context == null) {
                flag = true;
            }
        });
        if (flag) {
            getReport();
        }
    }


    //當滑鼠移到ETagcheckbox
    eTagWeekTimeFlow.eTagCheckBoxMouseover = function (mapMakers) {
        if (eTagWeekTimeFlow.map != null) {
            eTagWeekTimeFlow.chooseTabs = "eTag位置圖"
            eTagWeekTimeFlow.mapStyle = {};
            eTagWeekTimeFlow.chooseETag = mapMakers.title;
            eTagWeekTimeFlow.map.setCenter(eTagWeekTimeFlow.map.markers[mapMakers.id].getPosition());
            eTagWeekTimeFlow.map.setZoom(16);
        }
    };

    //當滑鼠離開ETagcheckbox
    eTagWeekTimeFlow.eTagCheckBoxMouseleave = function (mapMakers) {
        if (eTagWeekTimeFlow.chooseTabsFlag) {
            eTagWeekTimeFlow.chooseTabs = "報表清單";
            eTagWeekTimeFlow.mapStyle = { position: 'absolute', top: '-9999px' }
        }
        eTagWeekTimeFlow.chooseETag = ''
    };

    //點擊ETagcheckbox
    eTagWeekTimeFlow.eTagCheckBoxClick = function (mapMakers) {
        if (eTagWeekTimeFlow.map != null) {
            eTagWeekTimeFlow.map.setCenter(eTagWeekTimeFlow.map.markers[mapMakers.id].getPosition());
            eTagWeekTimeFlow.chooseETag = mapMakers.title
            eTagWeekTimeFlow.map.setZoom(16);
            eTagWeekTimeFlow.chooseType = true;
            angular.forEach(eTagWeekTimeFlow.mapMakers, function (value, key) {
                value.choose = false;
            });
            mapMakers.choose = !mapMakers.choose;
            var that = eTagWeekTimeFlow.map.markers[mapMakers.id];
            for (var i = 0; i < eTagWeekTimeFlow.mapMakers.length; i++) {
                if (eTagWeekTimeFlow.mapMakers[i].choose) {
                    eTagWeekTimeFlow.map.markers[eTagWeekTimeFlow.mapMakers[i].id].setAnimation(google.maps.Animation.BOUNCE);
                } else {
                    eTagWeekTimeFlow.map.markers[eTagWeekTimeFlow.mapMakers[i].id].setAnimation(null);
                }
            }
        }
    };

    //點擊地圖的Marker
    eTagWeekTimeFlow.eTagMarkerClick = function (event, mapMakers) {
        angular.forEach(eTagWeekTimeFlow.mapMakers, function (value, key) {
            value.choose = false;
        });
        mapMakers.choose = !mapMakers.choose;
        var that = eTagWeekTimeFlow.map.markers[mapMakers.id];
        for (var i = 0; i < eTagWeekTimeFlow.mapMakers.length; i++) {
            if (eTagWeekTimeFlow.mapMakers[i].choose) {
                eTagWeekTimeFlow.map.markers[eTagWeekTimeFlow.mapMakers[i].id].setAnimation(google.maps.Animation.BOUNCE);
            } else {
                eTagWeekTimeFlow.map.markers[eTagWeekTimeFlow.mapMakers[i].id].setAnimation(null);
            }
        }
    };

    //當地圖換位置重新使Marker有動畫
    eTagWeekTimeFlow.mapChange = function () {
        if (eTagWeekTimeFlow.map != null && eTagWeekTimeFlow.mapMakers != null) {
            for (var i = 0; i < eTagWeekTimeFlow.mapMakers.length; i++) {
                if (eTagWeekTimeFlow.mapMakers[i].choose) {
                    eTagWeekTimeFlow.map.markers[eTagWeekTimeFlow.mapMakers[i].id].setAnimation(google.maps.Animation.BOUNCE);
                } else {
                    eTagWeekTimeFlow.map.markers[eTagWeekTimeFlow.mapMakers[i].id].setAnimation(null);
                }
            }
        }
    };

    //按下重置
    eTagWeekTimeFlow.reset = function () {
        eTagWeekTimeFlow.search = {
            "startDate": getYyyNowDate(),
            "endDate": getYyyNowDate(),
            "eTag": "",
            "order": true,
            "eTagID": ""
        }
        for (var i = 0; i < eTagWeekTimeFlow.mapMakers.length; i++) {
            eTagWeekTimeFlow.mapMakers[i].choose = false;
            eTagWeekTimeFlow.map.markers[eTagWeekTimeFlow.mapMakers[i].id].setAnimation(null);
        }
        eTagWeekTimeFlow.notDateList = [];
        $timeout(changeDateColor, 10);
    }

    //產生報表
    eTagWeekTimeFlow.createReport = function () {
        if (eTagWeekTimeFlow.search.startDate <= eTagWeekTimeFlow.search.endDate) {
            canceller.resolve();
            var temp = [];
            var hasChoose = false;
            for (var i = 0; i < eTagWeekTimeFlow.mapMakers.length; i++) {
                if (eTagWeekTimeFlow.mapMakers[i].choose) {
                    var inTemp = {};
                    inTemp.id = eTagWeekTimeFlow.mapMakers[i].id;
                    inTemp.title = eTagWeekTimeFlow.mapMakers[i].title;
                    temp.push(inTemp);
                    hasChoose = true;
                }
            }
            if (hasChoose) {
                eTagWeekTimeFlow.searchBtnFlag = true;
                eTagWeekTimeFlow.buttonText = "傳輸中";
                eTagWeekTimeFlow.search.notDateList = eTagWeekTimeFlow.notDateList;
                eTagWeekTimeFlow.search.selectETag = temp;
                $http({
                    method: 'POST',
                    url: "api/eTagWeekTimeFlow/處理週內日分時流量資料",
                    data: eTagWeekTimeFlow.search
                }).then(function successCallback(response) {
                    if (response.data != "no") {
                        getReport();
                        eTagWeekTimeFlow.search.reportid = response.data;
                        getETagBaseDate();
                    } else {
                        alert("處理中的報表不可超過3個，請等待完成後再試。");
                        waitSomeTime();
                    }
                }, function errorCallback(response) {
                    alert("搜尋失敗，請聯絡資訊室。");
                });
            } else {
                alert('請至少選擇一個eTag');
            }
        } else {
            alert("開始日期不可大於結束日期。");
        }
    }

    //開始產生報表內容(這邊射後不理)
    function getETagBaseDate() {
        $http({
            method: 'POST',
            url: "api/eTagWeekTimeFlow/週內日分時流量資料",
            data: eTagWeekTimeFlow.search
        }).then(function successCallback(response) {
        }, function errorCallback(response) {
        });
    }

    //顯示日期介面
    eTagWeekTimeFlow.dateClick = function (id) {
        $('#' + id).datetimepicker('show');
    }

    //以下排除日期相關程式

    //清除日曆上所有active之class
    $(".datetimepicker-days tbody td").removeClass("active");

    //選擇日歷上的日期之監聽事件
    $('#notSearchDate').datetimepicker().on('changeDate', function (ev) {
        var flag = true;
        angular.forEach(eTagWeekTimeFlow.notDateList, function (value, key) {
            if (value.date == getDateChangeYyy(ev.date)) {
                flag = false;
            }
        });
        if (flag) {
            var temp = {
                id: notDateListID,
                date: getDateChangeYyy(ev.date)
            }
            eTagWeekTimeFlow.notDateList.push(temp);
            notDateListID = notDateListID + 1;
        } else {
            angular.forEach(eTagWeekTimeFlow.notDateList, function (value, key) {
                if (value.date == getDateChangeYyy(ev.date)) {
                    eTagWeekTimeFlow.notDateList.splice(key, 1);
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
        angular.forEach(eTagWeekTimeFlow.notDateList, function (value, key) {
            $("[data-date='" + value.date + "']").addClass("active");
        });
    }
});