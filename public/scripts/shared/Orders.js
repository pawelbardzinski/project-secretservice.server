(function() {
  var appOrder;

  appOrder = angular.module('app.order', ['app.services']);
  appOrder.controller('OrdersCtrl', [
    '$scope', '$filter', 'OrderService', 'Auth', 'ConfirmationProvider', 'uiHelper',
    function($scope, $filter, orderservice, Auth, ConfirmationProvider, uiHelper) {
      var init, load;
      $scope.searchKeywords = '';
      $scope.filteredOrders = [];
      $scope.row = '';
      $scope.isButtonSelected = true;
      var params = {};
      $scope.select = function(page) {
        var end, start;
        start = (page - 1) * $scope.numPerPage;
        end = start + $scope.numPerPage;
        return $scope.currentPageStores = $scope.filteredOrders.slice(start, end);
      };
      $scope.search = function() {
        $scope.filteredOrders = $filter('filter')($scope.orders, $scope.searchKeywords);
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
        params = {
          all: true
        }
        return orderservice.get(params, function(response) {
          $scope.orders = response.data;
          params = {}
          $scope.isButtonSelected = false;
        });
      }

      load = function() {
        return orderservice.get(params, function(response) {
          $scope.orders = response.data;
          $scope.allOrderSize = response.meta.size
          return init();
        });
      };
      init = function() {
        $scope.search();
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
}).call(this);


//# sourceMappingURL=Venues.js.map
