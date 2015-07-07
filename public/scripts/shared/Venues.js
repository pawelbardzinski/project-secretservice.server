(function() {
  var VenueModalCtrl, appVenue;

  appVenue = angular.module('app.venue', ['app.services']);

  appVenue.controller('VenuesCtrl', [
    '$scope', '$filter', 'VenueModalProvider', 'VenueService', 'Auth', 'ConfirmationProvider', 'uiHelper', function($scope, $filter, venueModalProvider, venueservice, Auth, ConfirmationProvider, uiHelper) {
      var init, load;
      $scope.searchKeywords = '';
      $scope.filteredVenues = [];
      $scope.row = '';
      $scope.select = function(page) {
        var end, start;
        start = (page - 1) * $scope.numPerPage;
        end = start + $scope.numPerPage;
        return $scope.currentPageStores = $scope.filteredVenues.slice(start, end);
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
        $scope.filteredVenues = $filter('filter')($scope.venues, $scope.searchKeywords);
        return $scope.onFilterChange();
      };
      $scope.order = function(rowName) {
        if ($scope.row === rowName) {
          return;
        }
        $scope.row = rowName;
        $scope.filteredVenues = $filter('orderBy')($scope.venues, rowName);
        return $scope.onOrderChange();
      };
      $scope.numPerPageOpt = [3, 5, 10, 20];
      $scope.numPerPage = $scope.numPerPageOpt[2];
      $scope.currentPage = 1;
      $scope.currentPageStores = [];
      load = function() {
        return venueservice.query(null, function(response) {
          $scope.venues = response;
          return init();
        });
      };
      init = function() {
        $scope.search();
        return $scope.select($scope.currentPage);
      };
      load();
      $scope.edit = function(venue) {
        return venueModalProvider.Create(venue.id).result.then(function() {
          return load();
        });
      };
      $scope["delete"] = function(venue) {
        return ConfirmationProvider.Create("Are you sure you want to delete venue: " + venue.name + "?").result.then(function() {
          return venueservice["delete"]({
            id: venue.id
          }, function(response) {
            return load();
          }, function(response) {
            return uiHelper.handleApiError($scope, response);
          });
        });
      };
      return $scope.add = function() {
        return venueModalProvider.Create(0).result.then(function() {
          return load();
        });
      };
    }
  ]);

  appVenue.controller('VenueProfileCtrl', [
    '$scope', '$filter', 'VenueService', 'Auth', 'uiHelper', function($scope, $filter, VenueService, Auth, uiHelper) {
      var venueId;
      venueId = Auth.getCurrentUser().venue_id;
      $scope.states = uiHelper.states;
      if (Auth.getCurrentUser().venue_id > 0) {
        VenueService.get({
          id: Auth.getCurrentUser().venue_id
        }, function(response) {
          return $scope.venue = response;
        });
      } else {
        VenueService["new"](null, function(response) {
          return $scope.venue = response;
        });
      }
      return $scope.save = function() {
        var promise;
        venueId = $scope.venue.id;
        promise = venueId === 0 ? VenueService.post($scope.venue) : VenueService.put({
          id: $scope.venue.id
        }, $scope.venue);
        return promise.$promise.then(function(response) {
          uiHelper.showSavedSuccess();
          return $scope.venue = response;
        })["catch"](function(response) {
          return uiHelper.handleApiError($scope, response);
        });
      };
    }
  ]);

  VenueModalCtrl = function($scope, $modalInstance, $filter, VenueService, Auth, uiHelper, venueId) {
    $scope.Title = 'Venue Management';
    $scope.states = uiHelper.states;
    if (venueId > 0) {
      VenueService.get({
        id: venueId
      }, function(response) {
        return $scope.venue = response;
      });
    } else {
      VenueService["new"](function(response) {
        return $scope.venue = response;
      });
    }
    $scope.save = function() {
      var promise;
      promise = venueId === 0 ? VenueService.post($scope.venue) : VenueService.put({
        id: $scope.venue.id
      }, $scope.venue);
      return promise.$promise.then(function(response) {
        $scope.venue = response;
        uiHelper.showSavedSuccess();
        return $modalInstance.close();
      })["catch"](function(response) {
        return uiHelper.handleApiError($scope, response);
      });
    };
    return $scope.cancel = function() {
      return $modalInstance.dismiss('close');
    };
  };

  appVenue.controller('VenueModalCtrl', [
    '$scope', '$modalInstance', '$filter', 'VenueService', 'Auth', 'uiHelper', 'venueId', function($scope, $modalInstance, $filter, VenueService, Auth, uiHelper, venueId) {
      return new VenueModalCtrl($scope, $modalInstance, $filter, VenueService, VenueService, Auth, uiHelper, venueId);
    }
  ]);

  appVenue.factory('VenueModalProvider', [
    '$modal', function($modal) {
      var provider;
      provider = {};
      provider.Create = function(venueId) {
        return $modal.open({
          templateUrl: '/views/venue/venue-modal.html',
          controller: VenueModalCtrl,
          controllerAs: 'VenueModalCtrl',
          size: 'lg',
          resolve: {
            venueId: function() {
              return venueId;
            }
          }
        });
      };
      return provider;
    }
  ]);

}).call(this);

//# sourceMappingURL=Venues.js.map
