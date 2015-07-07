'use strict';

mod = angular.module('app.controllers', [])

# overall control
mod.controller('AppCtrl', [
     '$rootScope','$scope'
    ($rootScope,$scope) ->
        $window = $(window)

        $scope.main =
            brand: 'Hiyah Admin'
            
        $scope.admin =
            layout: 'wide'          # 'boxed', 'wide'
            menu: 'vertical'        # 'horizontal', 'vertical'
            fixedHeader: true       # true, false
            fixedSidebar: false     # true, false

        $scope.$watch('admin', (newVal, oldVal) ->
            # manually trigger resize event to force morris charts to resize, a significant performance impact, enable for demo purpose only
            # if newVal.menu isnt oldVal.menu || newVal.layout isnt oldVal.layout
            #      $window.trigger('resize')

            if newVal.menu is 'horizontal' && oldVal.menu is 'vertical'
                 $rootScope.$broadcast('nav:reset')
                 return
            if newVal.fixedHeader is false && newVal.fixedSidebar is true
                if oldVal.fixedHeader is false && oldVal.fixedSidebar is false
                    $scope.admin.fixedHeader = true 
                    $scope.admin.fixedSidebar = true 
                if oldVal.fixedHeader is true && oldVal.fixedSidebar is true
                    $scope.admin.fixedHeader = false 
                    $scope.admin.fixedSidebar = false 
                return
            if newVal.fixedSidebar is true
                $scope.admin.fixedHeader = true
            if newVal.fixedHeader is false 
                $scope.admin.fixedSidebar = false

            return
        , true)

        $scope.color =
            primary:    '#1BB7A0'
            success:    '#94B758'
            info:       '#56BDF1'
            infoAlt:    '#7F6EC7'
            warning:    '#F3C536'
            danger:     '#FA7B58'

])

mod.controller('HeaderCtrl', [
    '$scope'
    ($scope) ->



])

mod.controller('NavContainerCtrl', [
    '$scope'
    ($scope) ->


])

mod.controller('NavCtrl', [
    '$scope', 'taskStorage', 'filterFilter'
    ($scope, taskStorage, filterFilter) ->
        # init
        tasks = $scope.tasks = taskStorage.get()
        $scope.taskRemainingCount = filterFilter(tasks, {completed: false}).length

        $scope.$on('taskRemaining:changed', (event, count) ->
            $scope.taskRemainingCount = count
        )
])

mod.controller('DashboardCtrl', [
    '$scope'
    ($scope) ->

])

mod.controller('ReportsCtrl', [
    '$scope'
    ($scope) ->

])

mod.controller('SignInCtrl', [
    '$scope','$log','$state','Auth'
    ($scope,$log,$state,Auth) ->
      $scope.user = {email:'',password:''}
      $scope.message = ''
      $scope.signin = () ->
        signinPromise = Auth.signin($scope.user.email,$scope.user.password)
        signinPromise.then((response) ->
          $state.go('venue.users')
          $log.info(response.email))          
        signinPromise.catch((response) ->        
          $scope.message = 'Invalid email or password.'
          $log.info(response))
])

mod.controller('SignOutCtrl', [
    '$state','Auth'
    ($state,Auth) ->
      Auth.signout()
      $state.go('public.signin')
])
    
    
mod.controller('ResetPasswordCtrl', [
    '$scope','$state','$stateParams','Auth','UserService','uiHelper'
    ($scope,$state,$stateParams,Auth, userService,uiHelper) ->
      token = $stateParams.token
      $scope.user = {email:'',password:''}
      getpromise = userService.getbytoken({id:token}
        (response) ->
            $scope.user.email = response.email        
        (response) ->
            $scope.message = response.statusText)
      $scope.update = () -> 
        promise = Auth.updatepassword($scope.user.email,$scope.user.password,token)
        promise.$promise.then((response) ->
          uiHelper.logSuccess('Your password has been reset.')
          $state.go('public.signin'))
        promise.$promise.catch((response) ->
            uiHelper.handleApiError($scope,response))
])
    
    
mod.controller('ForgotPasswordCtrl', [
    '$scope','$log','$state','Auth','uiHelper'
    ($scope,$log,$state,Auth,uiHelper) ->
      $scope.passwordreset = () ->
        promise = Auth.passwordreset($scope.email)
        promise.$promise.then((response) ->
          uiHelper.logSuccess( 'An email has been sent with instructions to reset your password.')
          $scope.message = 'An email has been sent with instructions to reset your password.')          
        promise.$promise.catch((response) ->
            uiHelper.handleApiError($scope,response))
])
mod.controller('flotChartCtrl', [
    '$scope'
    ($scope) ->

        # Line Chart
        lineChart1 = {}
        lineChart1.data1 = [[1,15],[2,20],[3,14],[4,10],[5,10],[6,20],[7,28],[8,26],[9,22]]
        lineChart1.data2 = [[1,1],[2,2],[3,1],[4,0],[5,1],[6,0],[7,2],[8,2],[9,2]]
        $scope.line1 = {}
        $scope.line2 = {}
        
        $scope.line2.data =  [
            data: lineChart1.data2
            label: 'Trend'
        ]
        
        $scope.line1.data = [
            data: lineChart1.data1
            label: 'Trend'
        ]
        
        $scope.line1.options = {
            series:
                lines:
                    show: true
                    fill: true
                    fillColor: { colors: [ { opacity: 0 }, { opacity: 0.3 } ] }
                points:
                    show: true
                    lineWidth: 2
                    fill: true
                    fillColor: "#ffffff"
                    symbol: "circle"
                    radius: 5
            colors: [$scope.color.primary, $scope.color.infoAlt]
            tooltip: true
            tooltipOpts:
                defaultTheme: false
            grid:
                hoverable: true
                clickable: true
                tickColor: "#f9f9f9"
                borderWidth: 1
                borderColor: "#eeeeee"
            xaxis:
                 ticks: [[1,'4 PM'],[2,'5 PM'],[3,'6 PM'],[4,'7 PM'],[5,'8 PM'],[6,'9 PM'],[7,'10 PM'],[8,'11 PM'],[9,'12 PM']]
        }
        
        $scope.line2.options = {
            series:
                lines:
                    show: true
                    fill: true
                    fillColor: { colors: [ { opacity: 0 }, { opacity: 0.1 } ] }
                points:
                    show: true
                    lineWidth: 2
                    fill: true
                    fillColor: "#ffffff"
                    symbol: "circle"
                    radius: 5
            colors: [$scope.color.primary, $scope.color.infoAlt]
            tooltip: true
            tooltipOpts:
                defaultTheme: false
            grid:
                hoverable: true
                clickable: true
                tickColor: "#f9f9f9"
                borderWidth: 1
                borderColor: "#eeeeee"
            xaxis:
                 ticks: [[1,'4 PM'],[2,'5 PM'],[3,'6 PM'],[4,'7 PM'],[5,'8 PM'],[6,'9 PM'],[7,'10 PM'],[8,'11 PM'],[9,'12 PM']]
        }

])
