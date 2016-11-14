app.config(function ($routeProvider, $locationProvider) {
    $routeProvider
     .when('/home', {
         templateUrl: 'template/home',
         controller: 'home as home'
     })
     .when('/oldHome', {
         templateUrl: 'template/oldHome',
         controller: 'oldHome as oldHome'
     })
     .when('/baseETagDateSearch', {
         templateUrl: 'template/baseETagDateSearch',
         controller: 'baseETagDateSearch as baseETagDateSearch'
     })
     .when('/eTagTimeFlow', {
         templateUrl: 'template/eTagTimeFlow',
         controller: 'eTagTimeFlow as eTagTimeFlow'
     })
     .when('/eTagWeekTimeFlow', {
         templateUrl: 'template/eTagWeekTimeFlow',
         controller: 'eTagWeekTimeFlow as eTagWeekTimeFlow'
     })
     .when('/eTagTravelTime', {
         templateUrl: 'template/eTagTravelTime',
         controller: 'eTagTravelTime as eTagTravelTime'
     })
     .when('/eTagWeekTravelTime', {
         templateUrl: 'template/eTagWeekTravelTime',
         controller: 'eTagWeekTravelTime as eTagWeekTravelTime'
     })
     .when('/chart1', {
         templateUrl: 'template/chart1',
         controller: 'chart1 as chart1'
     })
     
     .when('/eTagTimeFlowTwo', {
         templateUrl: 'template/eTagTimeFlowTwo',
         controller: 'eTagTimeFlowTwo as eTagTimeFlowTwo'
     })
     .when('/eTagTimeFlowWeek', {
         templateUrl: 'template/eTagTimeFlowWeek',
         controller: 'eTagTimeFlowWeek as eTagTimeFlowWeek'
     })
     .when('/eTagAllFlow', {
         templateUrl: 'template/eTagAllFlow',
         controller: 'eTagAllFlow as eTagAllFlow'
     })
     .when('/newCase', {
         templateUrl: 'template/newCase',
         controller: 'newCase as newCase'
     })
    .when('/caseList/:type', {
        templateUrl: 'template/caseList',
        controller: 'caseList as caseList'
    })
    .when('/searchCase/:type', {
        templateUrl: 'template/searchCase',
        controller: 'searchCase as searchCase'
    })
    .when('/userManager', {
        templateUrl: 'template/userManager',
        controller: 'userManager as userManager'
    })
    .when('/councilorManager', {
        templateUrl: 'template/councilorManager',
        controller: 'councilorManager as councilorManager'
    })
    .when('/zoneManager', {
        templateUrl: 'template/zoneManager',
        controller: 'zoneManager as zoneManager'
    })
    .when('/mailManager', {
        templateUrl: 'template/mailManager',
        controller: 'mailManager as mailManager'
    })
    .when('/jobTitleManager', {
        templateUrl: 'template/jobTitleManager',
        controller: 'jobTitleManager as jobTitleManager'
    })
    .otherwise({
        redirectTo: '/home'
    });
});

app.run(function ($q, $rootScope, $location, $route, $interval) {
    $rootScope.$on("$routeChangeStart", function (event, next, current) {
        if ($rootScope.canceller != null) {
            $rootScope.canceller.resolve();
            $interval.cancel($rootScope.reHome);
        }
    });
});