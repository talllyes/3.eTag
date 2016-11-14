/**
 * Kai-ng-ui 
 * version:1.0.0
 * Copyright 2016 
 */

/*
 * 類別kaiSearch
 * 功能：可指定複數輸入欄位搜尋特定複數資料欄位，來過濾後之物件，另可選擇是否搭配<uib-pagination>套件
 * 範例說明：
 * 
 * 初始化：
 * var controller=new kaiPage(option);
 * 
 * OPTION參數：
 * controllerScope:$scope                >ng控制器的$scope(必填)
 * controllerName:controller.temp        >變數(必填) 
 * watch:["a","b",...]                   >要監聽的變數，依變數內容篩選輸出結果，陣列形式
 * useUibPage:true                       >使否有使用uib，預設true
 * outPut:1                              >產生複數的物件，以itemsPerPage為基準
 * maxSize: 5                            >配合<uib-pagination>之max-size，預設5
 * itemsPerPage: 10                      >配合<uib-pagination>之items-per-page，預設10
 * orderBy: [$filter('orderBy'), "a", b] >啟用排序功能，a為要排序之欄位名稱，b為true或false
 * searchDate: ["A", "S"]                >啟用日期搜尋功能，A=1為民國年、A=2為西元年，S為日期欄位名稱
 * 
 * 
 * 事件
 * controller.setData(Data)         >於初使化後設置資料
 * controller.resetItemList()       >重建controller.itemList內容
 * controller.orderItem("a")        >排序用，a為欄位名稱，上面option要有
 * 
 ** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  
 * 產出結果
 * controller.nowList               >處理後之結果
 * controller.pageShow              >頁數為1則false，大於1則true
 * controller.startDate             >預設為資料最小日期，修改即會改變資料結果，上面option要有
 * controller.endDate               >預設為今日日期，修改即會改變資料結果，上面option要有
 * 
 ** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *  
 * 配合<uib-pagination>之參數
 * controller.currentPage           >配合<uib-pagination>之ng-model
 * controller.totalItems.length     >配合<uib-pagination>之total-items
 * 
 * 
 * 
 */

var kaiSearch = function kaiSearch(option) {
    var my = this;
    var controllerScope = option.controllerScope;
    var controllerName = option.controllerName;
    var watches = "";
    var watchItem = [];
    var searchColumn = ""
    var useUibPage = true;
    var outPut = 1;
    var searchDate = "searchDate";
    var searchDateType = "0";
    var groupList = [];
    var allList = [];
    var dateFilterList = [];
    var keyFilterList = [];
    var orderByList = [];
    var filterList = [];
    var orderBy = "";
    var inits = true;
    my.listOrderby = true;
    my.listOrderItem = "";
    my.startDate = "";
    my.endDate = "";
    my.maxSize = 5;
    my.itemsPerPage = "10";
    my.currentPage = 1;
    my.pageShow = false;

    my.setData = function (data) {
        allList = data;
        dateFilter();
        if (inits) {
            controllerScope.$watch(watches, function () {
                keyFilter();
            });
            var dateWatches = controllerName + ".startDate";
            dateWatches = dateWatches + "+" + controllerName + ".endDate";
            controllerScope.$watch(dateWatches, function () {
                dateFilter();
            });
            var sliceWatches = controllerName + ".itemsPerPage";
            sliceWatches = sliceWatches + "+" + controllerName + ".listOrderby";
            controllerScope.$watch(sliceWatches, function () {
                toSliceList();
            });
        }
        inits = false;
    }

    my.orderItem = function (text) {
        my.listOrderby = !my.listOrderby;
        my.listOrderItem = text;
        toOrderBy();
    }
    function dateFilter() {
        var flag = true;
        dateFilterList = [];
        if (searchDateType != 0) {
            angular.forEach(allList, function (temp, key) {
                var flag = true;
                var searchString = "";
                angular.forEach(temp, function (temp2, key2) {
                    if (key2 == searchDate) {
                        if (StringToDateTime(temp2, searchDateType) > StringToDateTime(my.endDate, searchDateType)) {
                            flag = false;
                        }
                        if (StringToDateTime(temp2, searchDateType) < StringToDateTime(my.startDate, searchDateType)) {
                            flag = false;
                        }
                    }
                });
                if (flag) {
                    dateFilterList.push(temp);
                }
            });
        } else {
            dateFilterList = allList;
        }
        keyFilter();
    }

    function keyFilter() {
        keyFilterList = [];
        var watchString = [];
        angular.forEach(watchItem, function (a, b) {
            var sKey = eval("my." + a);
            if (typeof (sKey) == "string") {
                var keySplit = sKey.split(" ");
                angular.forEach(keySplit, function (k) {
                    watchString.push(k);
                });
            }
        });
        angular.forEach(dateFilterList, function (temp, key) {
            var flag = true;
            var searchString = "";
            searchString = searchString + searchObj(temp);
            if (searchString != "") {
                angular.forEach(watchString, function (value) {
                    if (searchString.indexOf(value) == -1) {
                        flag = false;
                    }
                });
            }
            if (flag) {
                keyFilterList.push(temp);
            }
        });
        toOrderBy();
    };

    function searchObj(obj) {
        var searchString = "";
        angular.forEach(obj, function (temp2, key2) {
            if (key2 != "$$hashKey") {
                if (typeof (temp2) == 'object') {
                    searchString = searchString + searchObj(temp2);
                } else {
                    if (typeof (temp2) == 'object') {
                        searchString = searchString + searchObj(temp2);
                    } else {
                        searchString = searchString + temp2;
                    }
                }
            }
        });
        return searchString;
    }

    function toOrderBy() {
        if (orderBy != "") {
            orderByList = orderBy(keyFilterList, my.listOrderItem, my.listOrderby);
        } else {
            orderByList = keyFilterList;
        }
        toSliceList();
    }

    function toSliceList() {
        var listTemp = orderByList;
        my.totalItems = listTemp;
        if (useUibPage) {
            var lengths = listTemp.length / outPut;
            if ((listTemp.length % outPut) != 0) {
                lengths = lengths + 1;
            }
            if (outPut == 1) {
                var begin = (my.currentPage - 1) * parseInt(my.itemsPerPage);
                var end = begin + parseInt(my.itemsPerPage);
                my.nowList = listTemp.slice(begin, end);
            } else {
                my.totalItems = angular.copy(listTemp).slice(0, lengths);
                my.nowList = [];
                for (var i = 0; i < outPut; i++) {
                    var inBegin = (my.currentPage - 1) * parseInt(my.itemsPerPage) + ((my.currentPage - 1) * parseInt(my.itemsPerPage)) + (i * parseInt(my.itemsPerPage));
                    var inEnd = inBegin + parseInt(my.itemsPerPage);
                    my.nowList.push(listTemp.slice(inBegin, inEnd));
                }
            }
            setPageShow();
        } else {
            my.nowList = listTemp;
            my.totalItems = my.nowList;
            setPageShow();
        }
        if (endEvent != "") {
            endEvent();
        }
    }
    var endEvent = "";

    my.event = function (event, toDo) {
        if (event == "end") {
            endEvent = toDo;
        }
    }

    function setPageShow() {
        var i = my.totalItems.length / my.itemsPerPage;
        if (i > 1) {
            my.pageShow = true;
        } else {
            my.pageShow = false;
        }
    }
    function setWatch(array) {
        var first = true;
        watches = controllerName + ".currentPage";
        angular.forEach(watchItem, function (temp, key) {
            watches = watches + "+" + controllerName + "." + temp;
        });
    }
    function getNowDate(type) {
        var today = new Date();
        var year = today.getFullYear();
        var month = today.getMonth() + 1;
        var day = today.getDate();
        if ((month + "").length == 1) {
            month = "0" + month;
        }
        if ((day + "").length == 1) {
            day = "0" + day;
        }
        if (type == "1") {
            return (year - 1911) + "-" + month + "-" + day;
        } else if (type == "2") {
            return year + "-" + month + "-" + day;
        }
    }
    function StringToDateTime(date, type) {
        if (type == "1") {
            if (typeof (date) == "string") {
                try {
                    var year = parseInt(date.split('-')[0]) + 1911;
                    var tDate = new Date(year, date.split('-')[1], date.split('-')[2]);
                    return tDate;
                }
                catch (err) {
                    return new Date(1899, 1, 1);
                }
            } else {
                return new Date(1899, 1, 1);
            }
        } else {
            return new Date(date);
        }
    }

    (function init() {
        if (typeof (option.maxSizes) == 'number') {
            my.maxSize = option.maxSizes;
        }
        if (typeof (option.itemsPerPage) == 'number') {
            my.itemsPerPage = option.itemsPerPage + "";
        }
        if (typeof (option.watch) == 'object') {
            watchItem = option.watch;
        }
        if (typeof (option.searchDate) == 'object') {
            searchDateType = option.searchDate[0];
            my.startDate = getNowDate(searchDateType);
            my.endDate = getNowDate(searchDateType);
            searchDate = option.searchDate[1];
        }
        if (typeof (option.useUibPage) == 'boolean') {
            useUibPage = option.useUibPage;
        }
        if (typeof (option.orderBy) == 'object') {
            orderBy = option.orderBy[0];
            my.listOrderItem = option.orderBy[1];
            my.listOrderby = option.orderBy[2];
        }
        if (typeof (option.outPut) == 'number') {
            if (option.outPut > 0) {
                outPut = option.outPut;
            }
        }
        setWatch();
    })();
};