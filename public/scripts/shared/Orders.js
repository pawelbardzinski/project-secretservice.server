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
      $scope.onFilterChange = function() {
        $scope.select(1);
        $scope.currentPage = 1;
        return $scope.row = '';
      };
      $scope.onNumPerPageChange = function() {
        $scope.select(1);
        return $scope.currentPage = 1;
      };
      $scope.onOrderChange = function() {
        $scope.select(1);
        return $scope.currentPage = 1;
      };
      $scope.search = function() {
        $scope.filteredOrders = $filter('filter')($scope.orders, $scope.searchKeywords);
        return $scope.onFilterChange();
      };
      $scope.order = function(rowName) {
        if ($scope.row === rowName) {
          return;
        }
        $scope.row = rowName;
        $scope.filteredOrders = $filter('orderBy')($scope.orders, rowName);
        return $scope.onOrderChange();
      };
      $scope.numPerPageOpt = [3, 5, 10, 20];
      $scope.numPerPage = $scope.numPerPageOpt[2];
      $scope.currentPage = 1;
      $scope.currentPageStores = [];
      $scope.showAll = function() {
        params = {
          all: true
        }
        return orderservice.query(params, function(response) {
          $scope.orders = response;
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

}).call(this);

//# sourceMappingURL=Venues.js.map
