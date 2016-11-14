var app = angular.module('indexApp', ['ngRoute', 'ui.bootstrap', 'ngSanitize', 'ngMap']);
app.controller('index', function ($scope, $http, $interval) {
    var index = this;
    $('#editMyAD').on('hidden.bs.modal', function (e) {
        $('#indexBody').css("overflow-y", "scroll");
    })
    index.logout = function () {
        $http({
            method: 'GET',
            url: "api/login/登出"
        }).success(function (data, status, headers, config) {
            document.location.href = "login";
        });
    }
    if (index.checkLogin == null) {
        index.checkLogin = $interval(chechLogin, "60000");
    }
    function chechLogin() {
        $http({
            method: 'GET',
            url: "api/login/check"
        }).success(function (data, status, headers, config) {
            //if (data != "ok") {
            //    document.location.href = "login";
            //}
            console.log(data);
        });
    }
    $(document).on('click', 'li', function (event) {
        chechLogin();
    });
});

