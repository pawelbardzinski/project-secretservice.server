(function() {
  var ProductModalCtrl, appProduct;

  appProduct = angular.module('app.product', ['app.services']);

  appProduct.controller('ProductsCtrl', [
    '$scope', '$filter', 'ProductModalProvider', 'ProductService', 'Auth', 'ConfirmationProvider', 'uiHelper', function($scope, $filter, productModalProvider, productService, Auth, ConfirmationProvider, uiHelper) {
      var init, load;
      $scope.searchKeywords = '';
      $scope.filteredProducts = [];
      $scope.row = '';
      $scope.select = function(page) {
        var end, start;
        start = (page - 1) * $scope.numPerPage;
        end = start + $scope.numPerPage;
        return $scope.currentPageStores = $scope.filteredProducts.slice(start, end);
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
        $scope.filteredProducts = $filter('filter')($scope.products, $scope.searchKeywords);
        return $scope.onFilterChange();
      };
      $scope.order = function(rowName) {
        if ($scope.row === rowName) {
          return;
        }
        $scope.row = rowName;
        $scope.filteredProducts = $filter('orderBy')($scope.products, rowName);
        return $scope.onOrderChange();
      };
      $scope.numPerPageOpt = [3, 5, 10, 20];
      $scope.numPerPage = $scope.numPerPageOpt[2];
      $scope.currentPage = 1;
      $scope.currentPageStores = [];
      load = function() {
        return productService.query({
          venueId: Auth.getCurrentUser().venue_id
        }, function(response) {
          $scope.products = response;
          return init();
        });
      };
      init = function() {
        $scope.search();
        return $scope.select($scope.currentPage);
      };
      load();
      $scope.edit = function(Product) {
        return productModalProvider.Create(Product.id).result.then(function() {
          return load();
        });
      };
      $scope["delete"] = function(product) {
        return ConfirmationProvider.Create("Are you sure you want to delete product: " + product.name + "?").result.then(function() {
          return productService["delete"]({
            id: product.id,
            venueId: product.venue_id
          }, function(response) {
            return load();
          }, function(response) {
            return uiHelper.handleApiError($scope, response);
          });
        });
      };
      return $scope.add = function() {
        return productModalProvider.Create(0).result.then(function() {
          return load();
        });
      };
    }
  ]);

  ProductModalCtrl = function($scope, $modalInstance, ProductService, FileUploader, productId, Auth, uiHelper) {
    var uploader, url;
    $scope.Title = 'Product Management';
    url = '/v1/venues/' + Auth.getCurrentUser().venue_id + '/products/upload';
    uploader = $scope.uploader = new FileUploader({
      url: url,
      headers: {
        'x-application-id': 'com.secret-service.admin',
        'X-Requested-With': 'XMLHttpRequest',
        'x-auth-token': Auth.getCurrentUser().auth_token
      }
    });
    uploader.filters.push({
      name: 'imageFilter',
      fn: function(item, options) {
        var type;
        type = '|' + item.type.slice(item.type.lastIndexOf('/') + 1) + '|';
        return '|png|'.indexOf(type) !== -1;
      }
    });
    uploader.onAfterAddingFile = function(fileItem) {
      if (uploader.queue.length > 1) {
        return uploader.queue.splice(0, 1);
      }
    };
    uploader.onWhenAddingFileFailed = function(item, filter, options) {
      return uiHelper.logWarning('Invalid file: ' + item.name + '. The image must be a png file format.');
    };
    if (productId > 0) {
      ProductService.get({
        id: productId,
        venueId: Auth.getCurrentUser().venue_id
      }, function(response) {
        var date;
        $scope.product = response;
        date = (Date.now() * 10000) + 621355968000000000;
        return $scope.imagePath = '/images/' + $scope.product.id + '.png?ts=' + date;
      });
    } else {
      ProductService["new"]({
        venueId: Auth.getCurrentUser().venue_id
      }, function(response) {
        return $scope.product = response;
      });
    }
    $scope.save = function() {
      var promise;
      promise = productId === 0 ? ProductService.post({
        venueId: Auth.getCurrentUser().venue_id
      }, $scope.product) : ProductService.put({
        id: $scope.product.id,
        venueId: Auth.getCurrentUser().venue_id
      }, $scope.product);
      return promise.$promise.then(function(response) {
        $scope.product = response;
        if (uploader.queue.length > 0) {
          uploader.queue[0].file.name = response.id + '.png';
          uploader.queue[0].formData.push({
            imageName: response.id + '.png'
          });
          uploader.queue[0].upload();
        }
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

  appProduct.controller('ProductModalCtrl', [
    '$scope', '$modalInstance', 'ProductService', 'FileUploader', 'productId', 'Auth', 'uiHelper', function($scope, $modalInstance, ProductService, FileUploader, ProductId, Auth, uiHelper) {
      return new ProductModalCtrl($scope, $modalInstance, ProductService, productId, Auth, uiHelper);
    }
  ]);

  appProduct.factory('ProductModalProvider', [
    '$modal', function($modal) {
      var provider;
      provider = {};
      provider.Create = function(productId) {
        return $modal.open({
          templateUrl: '/views/products/product-modal.html',
          controller: ProductModalCtrl,
          controllerAs: 'ProductModalCtrl',
          size: 'lg',
          resolve: {
            productId: function() {
              return productId;
            }
          }
        });
      };
      return provider;
    }
  ]);

}).call(this);

//# sourceMappingURL=Products.js.map
