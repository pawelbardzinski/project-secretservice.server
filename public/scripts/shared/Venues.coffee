# CoffeeScript
# CoffeeScript

appVenue = angular.module('app.venue', ['app.services'])
appVenue.controller('VenuesCtrl', [
    '$scope'
    '$filter'
    'VenueModalProvider'
    'VenueService'
    'Auth'
    'ConfirmationProvider'
    'uiHelper'
    ($scope, $filter,venueModalProvider,venueservice,Auth,ConfirmationProvider,uiHelper) ->
        # filter

        $scope.searchKeywords = ''
        $scope.filteredVenues = []
        $scope.row = ''

        $scope.select = (page) ->
            start = (page - 1) * $scope.numPerPage
            end = start + $scope.numPerPage
            $scope.currentPageStores = $scope.filteredVenues.slice(start, end)
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
            $scope.filteredVenues = $filter('filter')($scope.venues, $scope.searchKeywords)
            $scope.onFilterChange()

        # orderBy
        $scope.order = (rowName)->
            if $scope.row == rowName
                return
            $scope.row = rowName
            $scope.filteredVenues = $filter('orderBy')($scope.venues, rowName)
            # console.log $scope.filteredStores
            $scope.onOrderChange()

        # pagination
        $scope.numPerPageOpt = [3, 5, 10, 20]
        $scope.numPerPage = $scope.numPerPageOpt[2]
        $scope.currentPage = 1
        $scope.currentPageStores = []
        
        load = ->
          venueservice.query(null
                      (response) ->
                            $scope.venues = response
                            init())
        # init
        init = ->
            $scope.search()
            $scope.select($scope.currentPage)
            
        load()

        $scope.edit = (venue) ->
          venueModalProvider.Create(venue.id)
          .result.then(()->
            load()) 
            
       

        $scope.delete = (venue) ->
          ConfirmationProvider.Create("Are you sure you want to delete venue: " + venue.name + "?")
          .result.then(()-> 
              venueservice.delete({id:venue.id}
                          (response) ->
                            load()                                
                          (response) ->
                            uiHelper.handleApiError($scope,response)))
                     
        $scope.add = () ->
          venueModalProvider.Create(0)
          .result.then(()->
            load())  
        
])

appVenue.controller('VenueProfileCtrl', [
    '$scope'
    '$filter'
    'VenueService'
    'Auth'
    'uiHelper'
    ($scope,$filter,VenueService,Auth,uiHelper) ->
        venueId =Auth.getCurrentUser().venue_id
        
        $scope.states = uiHelper.states
                  
        if(Auth.getCurrentUser().venue_id > 0 )
            VenueService.get({id:Auth.getCurrentUser().venue_id}
            (response) ->
                $scope.venue = response)
        else
            VenueService.new(null
            (response) ->
                $scope.venue = response)
      
        $scope.save = ()->
            venueId = $scope.venue.id
            promise = if venueId==0 then VenueService.post($scope.venue) else VenueService.put({id:$scope.venue.id},$scope.venue)
            promise.$promise.then((response) ->
                uiHelper.showSavedSuccess()
                $scope.venue = response)
            .catch((response) ->
                uiHelper.handleApiError($scope,response))
        
])


VenueModalCtrl = ($scope, $modalInstance,$filter,VenueService,Auth,uiHelper,venueId) ->
      $scope.Title='Venue Management'
      
      $scope.states = uiHelper.states
                  
      if(venueId >0 )
          VenueService.get({id:venueId}
            (response) ->
              $scope.venue = response)
      else
          VenueService.new(
            (response) ->
              $scope.venue = response)
      
      $scope.save = ()->
        promise = if venueId==0 then VenueService.post($scope.venue) else VenueService.put({id:$scope.venue.id},$scope.venue)
        promise.$promise.then((response) ->
            $scope.venue = response  
            uiHelper.showSavedSuccess()    
            $modalInstance.close())
        .catch((response) ->
            uiHelper.handleApiError($scope,response))
        
      $scope.cancel = ()->
        $modalInstance.dismiss('close');

appVenue.controller('VenueModalCtrl', [
    '$scope'
    '$modalInstance'
    '$filter'
    'VenueService'
    'Auth'
    'uiHelper'
    'venueId'
    ($scope, $modalInstance,$filter,VenueService,Auth,uiHelper,venueId) ->
      return new VenueModalCtrl($scope, $modalInstance,$filter,VenueService,VenueService,Auth,uiHelper,venueId)
])

appVenue.factory('VenueModalProvider', [
    '$modal'
    ($modal) ->
        provider = {};
        provider.Create = (venueId) -> 
            $modal.open({
                    templateUrl: '/views/venue/venue-modal.html'
                    controller: VenueModalCtrl
                    controllerAs: 'VenueModalCtrl'
                    size: 'lg'
                    resolve:
                        venueId: () ->
                            return venueId
                    })
        return provider
])