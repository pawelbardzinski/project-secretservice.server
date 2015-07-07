# CoffeeScript

appUser = angular.module('app.user', ['app.services'])
appUser.controller('UsersCtrl', [
    '$scope'
    '$filter'
    'UserModalProvider'
    'UserService'
    'Auth'
     'ConfirmationProvider'
     'uiHelper'
    ($scope, $filter,userModalProvider,userservice,Auth,ConfirmationProvider,uiHelper) ->
        # filter

        $scope.searchKeywords = ''
        $scope.filteredUsers = []
        $scope.row = ''

        $scope.select = (page) ->
            start = (page - 1) * $scope.numPerPage
            end = start + $scope.numPerPage
            $scope.currentPageStores = $scope.filteredUsers.slice(start, end)
            # console.log start
            # console.log end
            # console.log $scope.currentPageStores

        # on page change: change numPerPage, filtering string
        $scope.onFilterChange = ->
            $scope.select(1)
            $scope.currentPage = 1
            $scope.row = ''

        $scope.onNumPerPageChange = ->
            $scope.select(1)
            $scope.currentPage = 1

        $scope.onOrderChange = ->
            $scope.select(1)
            $scope.currentPage = 1            


        $scope.search = ->
            $scope.filteredUsers = $filter('filter')($scope.users, $scope.searchKeywords)
            $scope.onFilterChange()

        # orderBy
        $scope.order = (rowName)->
            if $scope.row == rowName
                return
            $scope.row = rowName
            $scope.filteredUsers = $filter('orderBy')($scope.users, rowName)
            # console.log $scope.filteredStores
            $scope.onOrderChange()

        # pagination
        $scope.numPerPageOpt = [3, 5, 10, 20]
        $scope.numPerPage = $scope.numPerPageOpt[2]
        $scope.currentPage = 1
        $scope.currentPageStores = []
        
        load = ->
          params = null
          params = {role:routingConfig.userRoles.waiter.bitMask | routingConfig.userRoles.venueadmin.bitMask}  if Auth.getCurrentUser().role.bitMask & routingConfig.userRoles.venueadmin.bitMask
          params = {role:routingConfig.userRoles.venueadmin.bitMask | routingConfig.userRoles.admin.bitMask} if Auth.getCurrentUser().role.bitMask & routingConfig.userRoles.admin.bitMask
          userservice.query(params
                      (response) ->
                            $scope.users = response
                            init())
        # init
        init = ->
            $scope.search()
            $scope.select($scope.currentPage)
            
        load()

        $scope.lookupRoleName = (roleBitMask) ->
          role = _.find(routingConfig.userRolesArray
                      (item) ->
                        return item.bitMask == roleBitMask
                    )
          return role.display

        $scope.edit = (user) ->
          userModalProvider.Create(user.id)
          .result.then(()->
            load()) 
                    
        
        $scope.delete = (user) ->
          ConfirmationProvider.Create("Are you sure you want to delete user: " + user.firstname + " " + user.lastname + "?")
          .result.then(()->  
              userservice.delete({id:user.id}
                          (response) ->
                            uiHelper.showDeletedSuccess()
                            load()
                          (response) ->
                            uiHelper.handleApiError($scope,response)))
                                        
        $scope.add = () ->
          userModalProvider.Create(0)
          .result.then(()->
            load())  
        
])

UserModalCtrl = ($scope, $modalInstance,$filter,UserService,VenueService,Auth,uiHelper,userId) ->
      $scope.Title='User Management'
      $scope.roles = routingConfig.userRolesArray
      $scope.adminRole = routingConfig.userRoles.admin.bitMask
      
      $scope.roles = $filter('filter')(routingConfig.userRolesArray,{venue_user:true}) if Auth.getCurrentUser().role.bitMask & routingConfig.userRoles.venueadmin.bitMask
      $scope.roles = $filter('filter')(routingConfig.userRolesArray,{is_admin:true}) if Auth.getCurrentUser().role.bitMask & routingConfig.userRoles.admin.bitMask
      
      VenueService.query(
        null
        (response)->
            $scope.venues = response)
            
      if(userId >0 )
          UserService.get({id:userId}
            (response) ->
              $scope.user = response)
      else
          UserService.new(
            (response) ->
              $scope.user = response)
      
      $scope.save = ()->
        $scope.user.venue_id = null if $scope.user.role == routingConfig.userRoles.admin.bitMask
        $scope.user.venue_id = Auth.getCurrentUser().venue_id if Auth.getCurrentUser().venue_id and userId==0
        
        promise = if userId==0 then UserService.post($scope.user) else UserService.put({id:$scope.user.id},$scope.user)
        promise.$promise.then((response) ->
          $scope.user = response    
          uiHelper.showSavedSuccess()
          $modalInstance.close())
        .catch((response) ->
            uiHelper.handleApiError($scope,response))
        
      $scope.cancel = ()->
        $modalInstance.dismiss('close');

appUser.controller('UserModalCtrl', [
    '$scope'
    '$modalInstance'
    '$filter'
    'UserService'
    'VenueService'
    'Auth'
    'uiHelper'
    'userId'
    ($scope, $modalInstance,$filter,UserService,VenueService,Auth,uiHelper,userId) ->
      return new UserModalCtrl($scope, $modalInstance,$filter,UserService,VenueService,Auth,uiHelper,userId)
])

appUser.factory('UserModalProvider', [
    '$modal'
    ($modal) ->
        provider = {};
        provider.Create = (userId) -> 
            $modal.open({
                    templateUrl: '/views/users/user-modal.html'
                    controller: UserModalCtrl
                    controllerAs: 'UserModalCtrl'
                    size: 'lg'
                    resolve:
                        userId: () ->
                            return userId
                    })
        return provider
])