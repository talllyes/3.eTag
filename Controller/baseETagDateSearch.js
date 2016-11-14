app.controller('baseETagDateSearch', function ($scope, $http, $routeParams, $timeout, NgMap, $q, $rootScope) {
    var baseETagDateSearch = this;
    var canceller = $q.defer();                                         //宣告ajax控制元件
    $rootScope.canceller = canceller;                                   //將本頁ajax控制元件給全域
    baseETagDateSearch.mapCenter = "22.624133,120.269429";              //初始位置
    baseETagDateSearch.mapZoom = 16;                                    //初始大小
    baseETagDateSearch.chooseTabs = "資料表格";                         //當前選擇的標籤
    baseETagDateSearch.chooseTabsFlag = true;                           //記憶用
    baseETagDateSearch.eTagBaseData = [];                               //偵測有沒有資料用
    baseETagDateSearch.chooseETag = "";                                 //顯示當前設備名稱
    baseETagDateSearch.searchBtnFlag = false;                           //搜尋按紐不可按
    baseETagDateSearch.mapStyle = {                                     //地圖先移到螢幕外面
        position: "absolute",
        top: "-9999px"
    }
    baseETagDateSearch.search = {                                       //搜尋條件
        "startDate": getYyyNowDate(),
        "endDate": getYyyNowDate(),
        "startHH": "00",
        "startMM": "00",
        "endHH": "23",
        "endMM": "59",
        "eTag": "",
        "order": true,
        "eTagID": ""
    }
    baseETagDateSearch.myPage = new kaiSearch({                         //宣告分頁元件
        controllerScope: $scope,
        controllerName: 'baseETagDateSearch.myPage',
        maxSize: 5,
        itemsPerPage: 10,
        watch: ["searchKey"],
    });



    //取得地圖
    NgMap.getMap().then(function (map) {
        baseETagDateSearch.map = map;
    });

    //取得ETag基本資料
    $http({
        method: 'GET',
        url: "api/baseETagDateSearch/取得eTag基本資料"
    }).then(function successCallback(response) {
        baseETagDateSearch.mapMakers = response.data;
    }, function errorCallback(response) {
    });

    //當滑鼠移到ETagcheckbox
    baseETagDateSearch.eTagCheckBoxMouseover = function (mapMakers) {
        if (baseETagDateSearch.map != null) {
            baseETagDateSearch.chooseTabs = "eTag位置圖"
            baseETagDateSearch.mapStyle = {};
            baseETagDateSearch.chooseETag = mapMakers.title;
            baseETagDateSearch.map.setCenter(baseETagDateSearch.map.markers[mapMakers.id].getPosition());
            baseETagDateSearch.map.setZoom(16);
        }
    };

    //當滑鼠離開ETagcheckbox
    baseETagDateSearch.eTagCheckBoxMouseleave = function (mapMakers) {
        if (baseETagDateSearch.chooseTabsFlag) {
            baseETagDateSearch.chooseTabs = "資料表格";
            baseETagDateSearch.mapStyle = { position: 'absolute', top: '-9999px' }
        }
        baseETagDateSearch.chooseETag = ''
    };

    //點擊ETagcheckbox
    baseETagDateSearch.eTagCheckBoxClick = function (mapMakers) {
        if (baseETagDateSearch.map != null) {
            baseETagDateSearch.map.setCenter(baseETagDateSearch.map.markers[mapMakers.id].getPosition());
            baseETagDateSearch.chooseETag = mapMakers.title
            baseETagDateSearch.map.setZoom(16);
            baseETagDateSearch.chooseTabs = "eTag位置圖"
            mapMakers.choose = !mapMakers.choose;
            var that = baseETagDateSearch.map.markers[mapMakers.id];
            if (that.getAnimation() != null) {
                that.setAnimation(null);
            } else {
                that.setAnimation(google.maps.Animation.BOUNCE);
            }
        }
    };

    //點擊地圖的Marker
    baseETagDateSearch.eTagMarkerClick = function (event, mapMakers) {
        mapMakers.choose = !mapMakers.choose;
        if (this.getAnimation() != null) {
            this.setAnimation(null);
        } else {
            this.setAnimation(google.maps.Animation.BOUNCE);
        }
    };

    //當地圖換位置重新使Marker有動畫
    baseETagDateSearch.mapChange = function () {
        if (baseETagDateSearch.map != null && baseETagDateSearch.mapMakers != null) {
            for (var i = 0; i < baseETagDateSearch.mapMakers.length; i++) {
                if (baseETagDateSearch.mapMakers[i].choose) {
                    baseETagDateSearch.map.markers[baseETagDateSearch.mapMakers[i].id].setAnimation(google.maps.Animation.BOUNCE);
                } else {
                    baseETagDateSearch.map.markers[baseETagDateSearch.mapMakers[i].id].setAnimation(null);
                }
            }
        }
    };

    //按下重置
    baseETagDateSearch.reset = function () {
        baseETagDateSearch.search = {
            "startDate": getYyyNowDate(),
            "endDate": getYyyNowDate(),
            "startHH": "00",
            "startMM": "00",
            "endHH": "23",
            "endMM": "59",
            "eTag": "",
            "order": true,
            "eTagID": ""
        };
        for (var i = 0; i < baseETagDateSearch.mapMakers.length; i++) {
            baseETagDateSearch.mapMakers[i].choose = false;
            baseETagDateSearch.map.markers[baseETagDateSearch.mapMakers[i].id].setAnimation(null);
        }
    }

    //按下搜尋
    baseETagDateSearch.getETagBaseDate = function () {
        var startDate = new Date(baseETagDateSearch.search.startDate + " " + baseETagDateSearch.search.startHH + ":" + baseETagDateSearch.search.startMM);
        var endDate = new Date(baseETagDateSearch.search.endDate + " " + baseETagDateSearch.search.endHH + ":" + baseETagDateSearch.search.endMM);
        if (startDate < endDate) {
            canceller.resolve();
            baseETagDateSearch.eTagBaseData = [];
            baseETagDateSearch.chooseTabs = "資料表格";
            baseETagDateSearch.mapStyle = { position: 'absolute', top: '-9999px' }
            baseETagDateSearch.chooseTabsFlag = true;
            baseETagDateSearch.searchBtnFlag = true;
            $(".showLoader").css("display", "");
            $(".showETagData").css("display", "none");
            $(".showETagData").css("opacity", "0");
            var temp = [];
            for (var i = 0; i < baseETagDateSearch.mapMakers.length; i++) {
                if (baseETagDateSearch.mapMakers[i].choose) {
                    temp.push(baseETagDateSearch.mapMakers[i].id);
                }
            }
            baseETagDateSearch.search.selectETag = temp;
            $http({
                method: 'POST',
                url: "api/baseETagDateSearch/eTag原始資料",
                data: baseETagDateSearch.search
            }).then(function successCallback(response) {
                baseETagDateSearch.myPage.setData(response.data);
                baseETagDateSearch.eTagBaseData = response.data;
                baseETagDateSearch.searchBtnFlag = false;
                $(".showLoader").css("display", "none");
                $(".showETagData").css("display", "");
                $(".showETagData").animate({ opacity: 1 }, 500);
            }, function errorCallback(response) {
                alert("搜尋失敗，請聯絡資訊室。");
            });
        } else {
            alert("開始日期不可大於結束日期。");
        }
    }

    //日期表格顯示
    baseETagDateSearch.dateClick = function (id) {
        $('#' + id).datetimepicker('show');
    }

    //檢查日期格式
    baseETagDateSearch.checkDate = function (type) {
        if (type == "shh") {
            var number = parseFloat(baseETagDateSearch.search.startHH);
            if (isNaN(number)) {
                baseETagDateSearch.search.startHH = "00";
            } else if (number > 23) {
                baseETagDateSearch.search.startHH = "00";
            }
        } else if (type == "smm") {
            var number = parseFloat(baseETagDateSearch.search.startMM);
            if (isNaN(number)) {
                baseETagDateSearch.search.startMM = "00";
            } else if (number > 59) {
                baseETagDateSearch.search.startMM = "00";
            }
        } else if (type == "ehh") {
            var number = parseFloat(baseETagDateSearch.search.endHH);
            if (isNaN(number)) {
                baseETagDateSearch.search.endHH = "23";
            } else if (number > 23) {
                baseETagDateSearch.search.endHH = "23";
            }
        } else if (type == "emm") {
            var number = parseFloat(baseETagDateSearch.search.endMM);
            if (isNaN(number)) {
                baseETagDateSearch.search.endMM = "59";
            } else if (number > 59) {
                baseETagDateSearch.search.endMM = "59";
            }
        }
    }
})