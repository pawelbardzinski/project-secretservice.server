'use strict';

angular.module('app', [
    # Angular modules
    'ui.router'
    'ngCookies'
    'ngAnimate'

    # 3rd Party Modules
    'ui.bootstrap'
    'easypiechart'
    'mgo-angular-wizard'
    'textAngular'
    'ui.tree'
    'ngMap'
    'ngTagsInput'
    'angular-intro'
    'angularFileUpload'

    # Custom modules
    'app.controllers'
    'app.directives'
    'app.localization'
    'app.nav'
    'app.task'
    'app.user'
    'app.product'
    'app.venue'
    'app.order'
    'app.confirmation'
    'app.ui.services'
])
.config([
    '$stateProvider'
    '$urlRouterProvider'
    ($stateProvider,$urlRouterProvider) ->
        access = routingConfig.accessLevels

        $stateProvider
        .state('public', {
            abstract: true
            template: "<ui-view/>"
            data: {
                access: access.public
            }
        })
        .state('public.signin', {
            url: '/signin'
            templateUrl: 'views/system/signin.html'
            controller: 'SignInCtrl'
        })
        .state('public.signout', {
            url: '/signout'
            controller: 'SignOutCtrl'
        })

        .state('public.forgotpassword', {
            url: '/forgot-password'
            controller: 'ForgotPasswordCtrl'
            templateUrl: 'views/system/forgot-password.html'
        })

        .state('public.resetpassword', {
            url: '/resetpassword/:token'
            controller: 'ResetPasswordCtrl'
            templateUrl: 'views/system/reset-password.html'
        })


        $stateProvider
        .state('admin', {
            abstract: true
            template: "<ui-view/>"
            data: {
                access: access.admin
            }
        })
        .state('admin.venues', {
            url: '/venues'
            templateUrl: 'views/venue/venues.html'
            controller: 'VenuesCtrl'
            data: {
                access: access.venues
            }
        })
        .state('admin.orders', {
            url: '/orders'
            templateUrl: 'views/order/orders.html'
            controller: 'OrdersCtrl'
            data: {
                access: access.orders
            }
        })


        $stateProvider
        .state('venue', {
            abstract: true
            template: "<ui-view/>"
        })
#        .state('venue.dashboard', {
#            url: '/dashboard'
#            templateUrl: 'views/venue/dashboard.html'
#            controller: 'DashboardCtrl'
#            data: {
#                access: access.dashboard
#            }
#        })

        .state('venue.profile', {
            url: '/venueprofile'
            templateUrl: 'views/venue/venue-profile.html'
            controller: 'VenueProfileCtrl'
            data: {
                access: access.venueprofile
            }
        })
        .state('venue.users', {
            url: '/users'
            templateUrl: 'views/users/users.html'
            controller: 'UsersCtrl'
            data: {
                access: access.users
            }
        })
        .state('venue.products', {
            url: '/products'
            templateUrl: 'views/products/products.html'
            controller: 'ProductsCtrl'
            data: {
                access: access.products
            }
        })

#        $urlRouterProvider.otherwise('/dashboard');

        $urlRouterProvider.otherwise('/users');

])
.run(($rootScope,$state,Auth,$http) ->


    $rootScope.$on("$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
      if !Auth.authorize(toState.data.access)
          $rootScope.error = "Seems like you tried accessing a route you don't have access to..."
          event.preventDefault();

          if fromState.url == '^'
             if Auth.isLoggedIn()
                  #$state.go('venue.dashboard')
                  $state.go('venue.users')
             else
                  $rootScope.error = null
                  $state.go('public.signin')
    )


    $http.defaults.headers.common['x-application-id'] = 'com.secret-service.admin'
    $http.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest'

)
