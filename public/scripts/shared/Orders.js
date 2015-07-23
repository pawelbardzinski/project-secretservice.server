(function() {
  var appOrder;

  appOrder = angular.module('app.order', ['app.services']);
  appOrder.controller('OrdersCtrl', [
    '$scope', '$filter', 'OrderService', 'Auth', 'ConfirmationProvider', 'uiHelper',
    function($scope, $filter, orderservice, Auth, ConfirmationProvider, uiHelper) {
      var maxDataToSee = 1000;
      var init, load;
      $scope.buttonIsDisabled = false;
      $scope.filteredOrders = [];
      $scope.searchKeywords = '';
      $scope.row = '';
      $scope.isButtonSelected = true;
      var params = {};
      $scope.select = function(page) {
        var end, start;
        start = (page - 1) * $scope.numPerPage;
        end = start + $scope.numPerPage;
        return $scope.currentPageStores = $scope.filteredOrders.slice(start, end);
      };
      $scope.order = function(rowName) {
        if ($scope.row === rowName) {
          return;
        }
        $scope.row = rowName;
        $scope.orders = $filter('orderBy')($scope.orders, rowName);
      };
      $scope.numPerPageOpt = [3, 5, 10, 20];
      $scope.numPerPage = $scope.numPerPageOpt[2];
      $scope.currentPage = 1;
      $scope.currentPageStores = [];
      $scope.showAll = function() {
        $scope.filteredOrders = $scope.orders;
        maxDataToSee = $scope.orders.length;
        $scope.buttonIsDisabled = true;
        $scope.firstElement = $filter('orderBy')($scope.orders, 'createdAt', '-')[0]
        $scope.lastestElement = $filter('orderBy')($scope.orders, 'createdAt', '-').slice(-1)[0]
        $scope.$broadcast('minMaxDateChange', [$scope.firstElement, $scope.lastestElement]);
        // params = {
        //   all: true
        // }
        // return orderservice.get(params, function(response) {
        //   $scope.orders = response.data;
        //   params = {}
        //   $scope.isButtonSelected = false;
        // });
      }

      $scope.$on('dateChange', function(event, mass) {
        $scope.filteredOrders = $filter('filter')($scope.orders, function(element) {
          date = Date.parse(element.created_at)
          if (mass[0] < date && date < mass[1]) {
            return element;
          }
        }).slice(0, maxDataToSee)
      });

      load = function() {
        return orderservice.get(params, function(response) {
          $scope.orders = response.data;
          $scope.filteredOrders = $filter('limitTo')(response.data, maxDataToSee)
          $scope.firstElement = $filter('orderBy')($scope.filteredOrders, 'createdAt', '-')[0]
          $scope.lastestElement = $filter('orderBy')($scope.filteredOrders, 'createdAt', '-').slice(-1)[0]
          $scope.$broadcast('minMaxDateChange', [$scope.firstElement, $scope.lastestElement]);
          if ($scope.orders.length == $scope.filteredOrders.length) {
            $scope.buttonIsDisabled = true;
          }
          $scope.numPerPageOpt.push($scope.orders.length);
          $scope.allOrderSize = response.meta.size
          return init();
        });
      };
      init = function() {
        return $scope.select($scope.currentPage);
      };
      load();
    }
  ]);

  appOrder.filter('pagination', function() {
    return function(input, start) {
      if (input) {
        return input.slice(start);
      }
    };
  });
  appOrder.controller('DatepickerCtrl', function($scope) {
    $scope.opened = []
    $scope.today = function() {
      dt = new Date();
      dt.setHours(0,0,0,0);
      dk = new Date();
      dk.setHours(0,0,0,0);
    };
    $scope.today();

    $scope.clear = function() {
      $scope.dt = null;
    };

    $scope.dtChanged = function() {
      $scope.$emit('dateChange', [$scope.dt, $scope.dk]);
    }

    $scope.dkChanged = function() {
      $scope.$emit('dateChange', [$scope.dt, $scope.dk]);
    }

    $scope.toggleMin = function() {
      $scope.minDate = $scope.minDate ? null : new Date();
      $scope.maxDate = $scope.maxDate ? null : new Date();
    };
    $scope.toggleMin();

    $scope.open = function($event, index) {
      $event.preventDefault();
      $event.stopPropagation();
      $scope.opened[index] = $scope.opened[index] ? false : true;
    };
    $scope.$on('minMaxDateChange', function(event, mass) {
      $scope.dt = new Date(Date.parse(mass[0].created_at));
      $scope.dt.setHours(0,0,0,0)
      $scope.minDate = new Date(Date.parse(mass[0].created_at));
      $scope.dk = new Date(Date.parse(mass[1].created_at));
      $scope.dk.setHours(23,59,0,0)
      $scope.maxDate = new Date(Date.parse(mass[1].created_at));
      $scope.$emit('dateChange', [$scope.dt, $scope.dk]);
    });

  });

}).call(this);




//# sourceMappingURL=Venues.js.map
