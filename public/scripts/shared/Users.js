(function() {
  var UserModalCtrl, appUser;

  appUser = angular.module('app.user', ['app.services']);

  appUser.controller('UsersCtrl', [
    '$scope', '$filter', 'UserModalProvider', 'UserService', 'Auth', 'ConfirmationProvider', 'uiHelper', function($scope, $filter, userModalProvider, userservice, Auth, ConfirmationProvider, uiHelper) {
      var init, load;
      $scope.searchKeywords = '';
      $scope.filteredUsers = [];
      $scope.row = '';
      $scope.select = function(page) {
        var end, start;
        start = (page - 1) * $scope.numPerPage;
        end = start + $scope.numPerPage;
        return $scope.currentPageStores = $scope.filteredUsers.slice(start, end);
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
        $scope.filteredUsers = $filter('filter')($scope.users, $scope.searchKeywords);
        return $scope.onFilterChange();
      };
      $scope.order = function(rowName) {
        if ($scope.row === rowName) {
          return;
        }
        $scope.row = rowName;
        $scope.filteredUsers = $filter('orderBy')($scope.users, rowName);
        return $scope.onOrderChange();
      };
      $scope.numPerPageOpt = [3, 5, 10, 20];
      $scope.numPerPage = $scope.numPerPageOpt[2];
      $scope.currentPage = 1;
      $scope.currentPageStores = [];
      load = function() {
        var params;
        params = null;
        // if (Auth.getCurrentUser().role.bitMask & routingConfig.userRoles.venueadmin.bitMask) {
        //   params = {
        //     role: routingConfig.userRoles.waiter.bitMask | routingConfig.userRoles.venueadmin.bitMask
        //   };
        // }
        // if (Auth.getCurrentUser().role.bitMask & routingConfig.userRoles.admin.bitMask) {
        //   params = {
        //     role: routingConfig.userRoles.venueadmin.bitMask | routingConfig.userRoles.admin.bitMask
        //   };
        // }
        return userservice.query(params, function(response) {
          $scope.users = response;
          return init();
        });
      };
      init = function() {
        $scope.search();
        return $scope.select($scope.currentPage);
      };
      load();
      $scope.lookupRoleName = function(roleBitMask) {
        var role;
        role = _.find(routingConfig.userRolesArray, function(item) {
          return item.bitMask === roleBitMask;
        });
        return role.display;
      };
      $scope.edit = function(user) {
        return userModalProvider.Create(user.id).result.then(function() {
          return load();
        });
      };
      $scope.checkIfCanDelete = function(){
        return Auth.getCurrentUser().role.bitMask == 8
      }
      $scope["delete"] = function(user) {
        return ConfirmationProvider.Create("Are you sure you want to delete user: " + user.firstname + " " + user.lastname + "?").result.then(function() {
          return userservice["delete"]({
            id: user.id
          }, function(response) {
            uiHelper.showDeletedSuccess();
            return load();
          }, function(response) {
            return uiHelper.handleApiError($scope, response);
          });
        });
      };
      return $scope.add = function() {
        return userModalProvider.Create(0).result.then(function() {
          return load();
        });
      };
    }
  ]);

  UserModalCtrl = function($scope, $modalInstance, $filter, UserService, VenueService, Auth, uiHelper, userId) {
    $scope.Title = 'User Management';
    $scope.roles = routingConfig.userRolesArray;
    $scope.adminRole = routingConfig.userRoles.admin.bitMask;
    if (Auth.getCurrentUser().role.bitMask & routingConfig.userRoles.venueadmin.bitMask) {
      $scope.roles = $filter('filter')(routingConfig.userRolesArray, {
        venue_user: true
      });
    }
    if (Auth.getCurrentUser().role.bitMask & routingConfig.userRoles.admin.bitMask) {
      $scope.roles = $filter('filter')(routingConfig.userRolesArray, {
        is_admin: true
      });
    }
    VenueService.query(null, function(response) {
      return $scope.venues = response;
    });
    if (userId > 0) {
      UserService.get({
        id: userId
      }, function(response) {
        return $scope.user = response;
      });
    } else {
      UserService["new"](function(response) {
        return $scope.user = response;
      });
    }
    $scope.save = function() {
      var promise;
      if ($scope.user.role === routingConfig.userRoles.admin.bitMask) {
        $scope.user.venue_id = null;
      }
      if (Auth.getCurrentUser().venue_id && userId === 0) {
        $scope.user.venue_id = Auth.getCurrentUser().venue_id;
      }
      promise = userId === 0 ? UserService.post($scope.user) : UserService.put({
        id: $scope.user.id
      }, $scope.user);
      return promise.$promise.then(function(response) {
        $scope.user = response;
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

  appUser.controller('UserModalCtrl', [
    '$scope', '$modalInstance', '$filter', 'UserService', 'VenueService', 'Auth', 'uiHelper', 'userId', function($scope, $modalInstance, $filter, UserService, VenueService, Auth, uiHelper, userId) {
      return new UserModalCtrl($scope, $modalInstance, $filter, UserService, VenueService, Auth, uiHelper, userId);
    }
  ]);

  appUser.factory('UserModalProvider', [
    '$modal', function($modal) {
      var provider;
      provider = {};
      provider.Create = function(userId) {
        return $modal.open({
          templateUrl: '/views/users/user-modal.html',
          controller: UserModalCtrl,
          controllerAs: 'UserModalCtrl',
          size: 'lg',
          resolve: {
            userId: function() {
              return userId;
            }
          }
        });
      };
      return provider;
    }
  ]);

}).call(this);

//# sourceMappingURL=Users.js.map
