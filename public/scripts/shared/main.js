(function() {
  'use strict';
  var mod;

  mod = angular.module('app.controllers', []);

  mod.controller('AppCtrl', [
    '$rootScope', '$scope', function($rootScope, $scope) {
      var $window;
      $window = $(window);
      $scope.main = {
        brand: 'Hiyah Admin'
      };
      $scope.admin = {
        layout: 'wide',
        menu: 'vertical',
        fixedHeader: true,
        fixedSidebar: false
      };
      $scope.$watch('admin', function(newVal, oldVal) {
        if (newVal.menu === 'horizontal' && oldVal.menu === 'vertical') {
          $rootScope.$broadcast('nav:reset');
          return;
        }
        if (newVal.fixedHeader === false && newVal.fixedSidebar === true) {
          if (oldVal.fixedHeader === false && oldVal.fixedSidebar === false) {
            $scope.admin.fixedHeader = true;
            $scope.admin.fixedSidebar = true;
          }
          if (oldVal.fixedHeader === true && oldVal.fixedSidebar === true) {
            $scope.admin.fixedHeader = false;
            $scope.admin.fixedSidebar = false;
          }
          return;
        }
        if (newVal.fixedSidebar === true) {
          $scope.admin.fixedHeader = true;
        }
        if (newVal.fixedHeader === false) {
          $scope.admin.fixedSidebar = false;
        }
      }, true);
      return $scope.color = {
        primary: '#1BB7A0',
        success: '#94B758',
        info: '#56BDF1',
        infoAlt: '#7F6EC7',
        warning: '#F3C536',
        danger: '#FA7B58'
      };
    }
  ]);

  mod.controller('HeaderCtrl', ['$scope', function($scope) {}]);

  mod.controller('NavContainerCtrl', ['$scope', function($scope) {}]);

  mod.controller('NavCtrl', [
    '$scope', 'taskStorage', 'filterFilter', function($scope, taskStorage, filterFilter) {
      var tasks;
      tasks = $scope.tasks = taskStorage.get();
      $scope.taskRemainingCount = filterFilter(tasks, {
        completed: false
      }).length;
      return $scope.$on('taskRemaining:changed', function(event, count) {
        return $scope.taskRemainingCount = count;
      });
    }
  ]);

  mod.controller('DashboardCtrl', ['$scope', function($scope) {}]);

  mod.controller('ReportsCtrl', ['$scope', function($scope) {}]);

  mod.controller('SignInCtrl', [
    '$scope', '$log', '$state', 'Auth', function($scope, $log, $state, Auth) {
      $scope.user = {
        email: '',
        password: ''
      };
      $scope.message = '';
      return $scope.signin = function() {
        var signinPromise;
        signinPromise = Auth.signin($scope.user.email, $scope.user.password);
        signinPromise.then(function(response) {
          $state.go('venue.users');
          return $log.info(response.email);
        });
        return signinPromise["catch"](function(response) {
          $scope.message = 'Invalid email or password.';
          return $log.info(response);
        });
      };
    }
  ]);

  mod.controller('SignOutCtrl', [
    '$state', 'Auth', function($state, Auth) {
      Auth.signout();
      return $state.go('public.signin');
    }
  ]);

  mod.controller('ResetPasswordCtrl', [
    '$scope', '$state', '$stateParams', 'Auth', 'UserService', 'uiHelper', function($scope, $state, $stateParams, Auth, userService, uiHelper) {
      var getpromise, token;
      token = $stateParams.token;
      $scope.user = {
        email: '',
        password: ''
      };
      getpromise = userService.getbytoken({
        id: token
      }, function(response) {
        return $scope.user.email = response.email;
      }, function(response) {
        return $scope.message = response.statusText;
      });
      return $scope.update = function() {
        var promise;
        promise = Auth.updatepassword($scope.user.email, $scope.user.password, token);
        promise.$promise.then(function(response) {
          uiHelper.logSuccess('Your password has been reset.');
          return $state.go('public.signin');
        });
        return promise.$promise["catch"](function(response) {
          return uiHelper.handleApiError($scope, response);
        });
      };
    }
  ]);

  mod.controller('ForgotPasswordCtrl', [
    '$scope', '$log', '$state', 'Auth', 'uiHelper', function($scope, $log, $state, Auth, uiHelper) {
      return $scope.passwordreset = function() {
        var promise;
        promise = Auth.passwordreset($scope.email);
        promise.$promise.then(function(response) {
          uiHelper.logSuccess('An email has been sent with instructions to reset your password.');
          return $scope.message = 'An email has been sent with instructions to reset your password.';
        });
        return promise.$promise["catch"](function(response) {
          return uiHelper.handleApiError($scope, response);
        });
      };
    }
  ]);

  mod.controller('flotChartCtrl', [
    '$scope', function($scope) {
      var lineChart1;
      lineChart1 = {};
      lineChart1.data1 = [[1, 15], [2, 20], [3, 14], [4, 10], [5, 10], [6, 20], [7, 28], [8, 26], [9, 22]];
      lineChart1.data2 = [[1, 1], [2, 2], [3, 1], [4, 0], [5, 1], [6, 0], [7, 2], [8, 2], [9, 2]];
      $scope.line1 = {};
      $scope.line2 = {};
      $scope.line2.data = [
        {
          data: lineChart1.data2,
          label: 'Trend'
        }
      ];
      $scope.line1.data = [
        {
          data: lineChart1.data1,
          label: 'Trend'
        }
      ];
      $scope.line1.options = {
        series: {
          lines: {
            show: true,
            fill: true,
            fillColor: {
              colors: [
                {
                  opacity: 0
                }, {
                  opacity: 0.3
                }
              ]
            }
          },
          points: {
            show: true,
            lineWidth: 2,
            fill: true,
            fillColor: "#ffffff",
            symbol: "circle",
            radius: 5
          }
        },
        colors: [$scope.color.primary, $scope.color.infoAlt],
        tooltip: true,
        tooltipOpts: {
          defaultTheme: false
        },
        grid: {
          hoverable: true,
          clickable: true,
          tickColor: "#f9f9f9",
          borderWidth: 1,
          borderColor: "#eeeeee"
        },
        xaxis: {
          ticks: [[1, '4 PM'], [2, '5 PM'], [3, '6 PM'], [4, '7 PM'], [5, '8 PM'], [6, '9 PM'], [7, '10 PM'], [8, '11 PM'], [9, '12 PM']]
        }
      };
      return $scope.line2.options = {
        series: {
          lines: {
            show: true,
            fill: true,
            fillColor: {
              colors: [
                {
                  opacity: 0
                }, {
                  opacity: 0.1
                }
              ]
            }
          },
          points: {
            show: true,
            lineWidth: 2,
            fill: true,
            fillColor: "#ffffff",
            symbol: "circle",
            radius: 5
          }
        },
        colors: [$scope.color.primary, $scope.color.infoAlt],
        tooltip: true,
        tooltipOpts: {
          defaultTheme: false
        },
        grid: {
          hoverable: true,
          clickable: true,
          tickColor: "#f9f9f9",
          borderWidth: 1,
          borderColor: "#eeeeee"
        },
        xaxis: {
          ticks: [[1, '4 PM'], [2, '5 PM'], [3, '6 PM'], [4, '7 PM'], [5, '8 PM'], [6, '9 PM'], [7, '10 PM'], [8, '11 PM'], [9, '12 PM']]
        }
      };
    }
  ]);

}).call(this);

//# sourceMappingURL=main.js.map
