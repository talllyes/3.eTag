app.controller('eTagTimeFlow', function ($scope, $http, $routeParams, $timeout, NgMap, $q, $rootScope) {
    var eTagTimeFlow = this;
    eTagTimeFlow.mapCenter = "22.624133,120.269429";                //地圖初始位置
    eTagTimeFlow.mapZoom = 16;                                      //地圖初始大小
    eTagTimeFlow.chooseTabs = "資料表格";                           //當前選擇的標籤
    eTagTimeFlow.chooseTabsFlag = true;                             //記憶用
    eTagTimeFlow.searchBtnFlag = false;                             //搜尋按紐不可按
    eTagTimeFlow.eTagTimeFlowBaseData = [];                         //偵測有沒有資料用
    eTagTimeFlow.eTagTimeFlowData = [];                             //當前選擇的eTag資料
    eTagTimeFlow.eTagList = [];                                     //eTag清單
    eTagTimeFlow.mapStyle = {                                       //地圖先移到螢幕外面
        position: "absolute",
        top: "-9999px"
    }
    eTagTimeFlow.search = {                                         //搜尋條件
        "startDate": getYyyNowDate(),
        "endDate": getYyyNowDate(),
        "eTag": "",
        "order": true,
        "eTagID": ""
    }
    var canceller = $q.defer();                                     //宣告ajax控制元件
    $rootScope.canceller = canceller;                               //將本頁ajax控制元件給全域


    //取得地圖
    NgMap.getMap().then(function (map) {
        eTagTimeFlow.map = map;
    });

    //取得ETag基本資料
    $http({
        method: 'GET',
        url: "api/eTagTimeFlow/取得eTag基本資料"
    }).then(function successCallback(response) {
        eTagTimeFlow.mapMakers = response.data;
    }, function errorCallback(response) {
    });

    //當滑鼠移到ETagcheckbox
    eTagTimeFlow.eTagCheckBoxMouseover = function (mapMakers) {
        if (eTagTimeFlow.map != null) {
            eTagTimeFlow.chooseTabs = "eTag位置圖"
            eTagTimeFlow.mapStyle = {};
            eTagTimeFlow.chooseETag = mapMakers.title;
            eTagTimeFlow.map.setCenter(eTagTimeFlow.map.markers[mapMakers.id].getPosition());
            eTagTimeFlow.map.setZoom(16);
        }
    };

    //當滑鼠離開ETagcheckbox
    eTagTimeFlow.eTagCheckBoxMouseleave = function (mapMakers) {
        if (eTagTimeFlow.chooseTabsFlag) {
            eTagTimeFlow.chooseTabs = "資料表格";
            eTagTimeFlow.mapStyle = { position: 'absolute', top: '-9999px' }
        }
        eTagTimeFlow.chooseETag = ''
    };

    //點擊ETagcheckbox
    eTagTimeFlow.eTagCheckBoxClick = function (mapMakers) {
        if (eTagTimeFlow.map != null) {
            eTagTimeFlow.map.setCenter(eTagTimeFlow.map.markers[mapMakers.id].getPosition());
            eTagTimeFlow.chooseETag = mapMakers.title
            eTagTimeFlow.map.setZoom(16);
            eTagTimeFlow.chooseTabs = "eTag位置圖"
            mapMakers.choose = !mapMakers.choose;
            var that = eTagTimeFlow.map.markers[mapMakers.id];
            if (that.getAnimation() != null) {
                that.setAnimation(null);
            } else {
                that.setAnimation(google.maps.Animation.BOUNCE);
            }
        }
    };

    //點擊地圖的Marker
    eTagTimeFlow.eTagMarkerClick = function (event, mapMakers) {
        mapMakers.choose = !mapMakers.choose;
        if (this.getAnimation() != null) {
            this.setAnimation(null);
        } else {
            this.setAnimation(google.maps.Animation.BOUNCE);
        }
    };

    //當地圖換位置重新使Marker有動畫
    eTagTimeFlow.mapChange = function () {
        if (eTagTimeFlow.map != null && eTagTimeFlow.mapMakers != null) {
            for (var i = 0; i < eTagTimeFlow.mapMakers.length; i++) {
                if (eTagTimeFlow.mapMakers[i].choose) {
                    eTagTimeFlow.map.markers[eTagTimeFlow.mapMakers[i].id].setAnimation(google.maps.Animation.BOUNCE);
                } else {
                    eTagTimeFlow.map.markers[eTagTimeFlow.mapMakers[i].id].setAnimation(null);
                }
            }
        }
    };

    //按下重置
    eTagTimeFlow.reset = function () {
        eTagTimeFlow.search = {
            "startDate": getYyyNowDate(),
            "endDate": getYyyNowDate(),
            "eTag": "",
            "order": true,
            "eTagID": ""
        }
        for (var i = 0; i < eTagTimeFlow.mapMakers.length; i++) {
            eTagTimeFlow.mapMakers[i].choose = false;
            eTagTimeFlow.map.markers[eTagTimeFlow.mapMakers[i].id].setAnimation(null);
        }
    }

    //按下搜尋
    eTagTimeFlow.getETagBaseDate = function () {
        canceller.resolve();
        var temp = [];
        var hasChoose = false;
        for (var i = 0; i < eTagTimeFlow.mapMakers.length; i++) {
            if (eTagTimeFlow.mapMakers[i].choose) {
                var inTemp = {};
                inTemp.id = eTagTimeFlow.mapMakers[i].id;
                inTemp.title = eTagTimeFlow.mapMakers[i].title;
                temp.push(inTemp);
                hasChoose = true;
            }
        }
        if (hasChoose) {
            eTagTimeFlow.chooseTabs = "資料表格";
            eTagTimeFlow.mapStyle = { position: 'absolute', top: '-9999px' }
            eTagTimeFlow.chooseTabsFlag = true;
            eTagTimeFlow.searchBtnFlag = true;
            eTagTimeFlow.eTagTimeFlowBaseData = [];
            eTagTimeFlow.eTagList = [];
            eTagTimeFlow.eTagBaseInfo = "";
            $(".showLoader").css("display", "");
            $(".showETagData").css("display", "none");
            $(".showETagData").css("opacity", "0");
            eTagTimeFlow.search.selectETag = temp;
            $http({
                method: 'POST',
                url: "api/eTagTimeFlow/分時流量資料",
                data: eTagTimeFlow.search
            }).then(function successCallback(response) {
                eTagTimeFlow.searchBtnFlag = false;
                eTagTimeFlow.eTagTimeFlowBaseData = response.data;
                angular.forEach(eTagTimeFlow.eTagTimeFlowBaseData, function (value, key) {
                    eTagTimeFlow.eTagList.push(key);
                });
                eTagTimeFlow.eTagBaseInfo = eTagTimeFlow.eTagTimeFlowBaseData[eTagTimeFlow.eTagList[0]].baseInfo;
                eTagTimeFlow.eTagTimeFlowData = eTagTimeFlow.eTagTimeFlowBaseData[eTagTimeFlow.eTagList[0]].report;
                eTagTimeFlow.nowListSelect = eTagTimeFlow.eTagList[0];
                $(".showLoader").css("display", "none");
                $(".showETagData").css("display", "");
                $(".showETagData").animate({ opacity: 1 }, 500);
            }, function errorCallback(response) {
                alert("搜尋失敗，請聯絡資訊室。");
            });
        } else {
            alert('請至少選擇一個eTag');
        }
    }

    //從清單中選擇eTag
    eTagTimeFlow.eTagListClick = function () {
        eTagTimeFlow.eTagBaseInfo = eTagTimeFlow.eTagTimeFlowBaseData[eTagTimeFlow.nowListSelect].baseInfo;
        eTagTimeFlow.eTagTimeFlowData = eTagTimeFlow.eTagTimeFlowBaseData[eTagTimeFlow.nowListSelect].report;
    }

    //日期介面顯示
    eTagTimeFlow.dateClick = function (id) {
        $('#searchStartDate').datetimepicker('show');
    }

})