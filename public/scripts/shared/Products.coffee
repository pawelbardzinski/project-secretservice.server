# CoffeeScript
# CoffeeScript

appProduct = angular.module('app.product', ['app.services'])

appProduct.controller('ProductsCtrl', [
    '$scope'
    '$filter'
    'ProductModalProvider'
    'ProductService'
    'Auth'
    'ConfirmationProvider'
    'uiHelper'
    ($scope, $filter,productModalProvider,productService,Auth,ConfirmationProvider,uiHelper) ->
        
        $scope.searchKeywords = ''
        $scope.filteredProducts = []
        $scope.row = ''

        $scope.select = (page) ->
            start = (page - 1) * $scope.numPerPage
            end = start + $scope.numPerPage
            $scope.currentPageStores = $scope.filteredProducts.slice(start, end)
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
            $scope.filteredProducts = $filter('filter')($scope.products, $scope.searchKeywords)
            $scope.onFilterChange()

        # orderBy
        $scope.order = (rowName)->
            if $scope.row == rowName
                return
            $scope.row = rowName
            $scope.filteredProducts = $filter('orderBy')($scope.products, rowName)
            # console.log $scope.filteredStores
            $scope.onOrderChange()

        # pagination
        $scope.numPerPageOpt = [3, 5, 10, 20]
        $scope.numPerPage = $scope.numPerPageOpt[2]
        $scope.currentPage = 1
        $scope.currentPageStores = []
        
        load = ->
          productService.query(
            {venueId:Auth.getCurrentUser().venue_id}
            (response) ->
               $scope.products = response
               init())
        # init
        init = ->
            $scope.search()
            $scope.select($scope.currentPage)
            
        load()

        $scope.edit = (Product) ->
          productModalProvider.Create(Product.id)
          .result.then(()->
            load()) 
        
        $scope.delete = (product) ->
          ConfirmationProvider.Create("Are you sure you want to delete product: " + product.name + "?")
          .result.then(()->          
            productService.delete({id:product.id, venueId:product.venue_id}
                (response) ->
                    load()                   
                (response) ->
                    uiHelper.handleApiError($scope,response)))
                     
        $scope.add = () ->
          productModalProvider.Create(0)
          .result.then(()->
            load())  
        
])

ProductModalCtrl = ($scope, $modalInstance,ProductService,FileUploader,productId,Auth,uiHelper) ->
    $scope.Title='Product Management'
    url = '/v1/venues/' + Auth.getCurrentUser().venue_id + '/products/upload'
    uploader = $scope.uploader = new FileUploader({
        url: url,
        headers: {
                    'x-application-id': 'com.secret-service.admin'
                    'X-Requested-With': 'XMLHttpRequest' 
                    'x-auth-token': Auth.getCurrentUser().auth_token  }
    })
        
       
    uploader.filters.push({
            name: 'imageFilter',
            fn: (item, options) ->
                type = '|' + item.type.slice(item.type.lastIndexOf('/') + 1) + '|'
                return '|png|'.indexOf(type) != -1
        });
    
    
    uploader.onAfterAddingFile = (fileItem) ->
        uploader.queue.splice(0, 1) if uploader.queue.length > 1
        
    uploader.onWhenAddingFileFailed = (item, filter, options) ->
        uiHelper.logWarning('Invalid file: ' + item.name + '. The image must be a png file format.')
        
    if(productId >0 )
        ProductService.get({id:productId,venueId:Auth.getCurrentUser().venue_id}
          (response) ->
            $scope.product = response
            date = (Date.now() * 10000) + 621355968000000000
            $scope.imagePath = '/images/' + $scope.product.id + '.png?ts=' + date)
    else
        ProductService.new({venueId:Auth.getCurrentUser().venue_id}
          (response) ->
            $scope.product = response)
    
    $scope.save = ()->
      promise = if productId==0 then ProductService.post({venueId:Auth.getCurrentUser().venue_id},$scope.product) else ProductService.put({id:$scope.product.id,venueId:Auth.getCurrentUser().venue_id},$scope.product)
      promise.$promise.then((response) ->
        $scope.product = response
        if(uploader.queue.length>0)
            uploader.queue[0].file.name = response.id + '.png'
            uploader.queue[0].formData.push({imageName:response.id + '.png'})
            uploader.queue[0].upload()  
        uiHelper.showSavedSuccess()
        $modalInstance.close()
        )
      .catch((response) ->
        uiHelper.handleApiError($scope,response))
      
    $scope.cancel = ()->
      $modalInstance.dismiss('close');

appProduct.controller('ProductModalCtrl', [
    '$scope'
    '$modalInstance'
    'ProductService'    
    'FileUploader'
    'productId'
    'Auth'
    'uiHelper'
    ($scope, $modalInstance,ProductService,FileUploader,ProductId,Auth,uiHelper) ->    
      return new ProductModalCtrl($scope, $modalInstance,ProductService,productId,Auth,uiHelper)            
])

appProduct.factory('ProductModalProvider', [
    '$modal'
    ($modal) ->
        provider = {};
        provider.Create = (productId) -> 
            $modal.open({
              templateUrl: '/views/products/product-modal.html'
              controller: ProductModalCtrl
              controllerAs: 'ProductModalCtrl'
              size: 'lg'
              resolve:
                productId: () ->
                  return productId
            })
        return provider
])