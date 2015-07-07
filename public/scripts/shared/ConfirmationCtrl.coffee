# CoffeeScript

appConfirmation = angular.module('app.confirmation', [])
ConfirmationCtrl = ($scope, $modalInstance,message) ->
      $scope.Title='Confirmation'
      $scope.message = message
      $scope.ok = ()->
        $modalInstance.close()
        
      $scope.cancel = ()->
        $modalInstance.dismiss('close');

appConfirmation.controller('ConfirmationCtrl', [
    '$scope'
    '$modalInstance'
    'message'
    ($scope, $modalInstance,message) ->
      return new UserModalCtrl($scope, $modalInstance,message)
])

appConfirmation.factory('ConfirmationProvider', [
    '$modal'
    ($modal) ->
        provider = {};
        provider.Create = (message) -> 
            $modal.open({
                    templateUrl: '/views/system/confirmation.html'
                    controller: ConfirmationCtrl
                    controllerAs: 'ConfirmationCtrl'
                    size: 'sm'
                    resolve:
                        message: () ->
                            return message
                    })
        return provider
])