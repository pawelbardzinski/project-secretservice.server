(function() {
  var appExpandable;

  appExpandable = angular.module('app.expandable', ['app.services']);
  appExpandable.controller('ExpandablesCtrl', [
    '$scope', '$filter', 'ExpandableService', 'Auth', 'ConfirmationProvider', 'uiHelper', function($scope, $filter, expandableservice, Auth, ConfirmationProvider, uiHelper) {
      var init, load;
      $scope.searchKeywords = '';
      $scope.filteredExpandables = [];
      $scope.row = '';
      $scope.select = function(page) {
        var end, start;
        start = (page - 1) * $scope.numPerPage;
        end = start + $scope.numPerPage;
        return $scope.currentPageStores = $scope.filteredExpandables.slice(start, end);
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
        $scope.filteredExpandables = $filter('filter')($scope.expandables, $scope.searchKeywords);
        return $scope.onFilterChange();
      };
      $scope.order = function(rowName) {
        if ($scope.row === rowName) {
          return;
        }
        $scope.row = rowName;
        $scope.filteredExpandables = $filter('orderBy')($scope.expandables, rowName);
        return $scope.onOrderChange();
      };
      $scope.numPerPageOpt = [3, 5, 10, 20];
      $scope.numPerPage = $scope.numPerPageOpt[2];
      $scope.currentPage = 1;
      $scope.currentPageStores = [];
      load = function() {
        return expandableservice.query(null, function(response) {
          $scope.expandables = response;
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
