angular.module('app.services', ['ngResource'])        
.factory('Auth',[
  '$rootScope'
  '$http'
  '$q'
  '$window'
  'SessionService'
  ($rootScope,$http, $q,$window, SessionService)->        
    $rootScope.accessLevels = accessLevels = routingConfig.accessLevels
    $rootScope.userRoles = userRoles = routingConfig.userRoles
    $rootScope.currentUser = { username: '', role: userRoles.public } unless $window.sessionStorage.user
    $rootScope.currentUser = angular.fromJson($window.sessionStorage.user) if $window.sessionStorage.user
    $http.defaults.headers.common['x-auth-token'] = $rootScope.currentUser.auth_token  
   
   
    findUserRoleByBitMask = (roleBitMask)->
        return _.find(routingConfig.userRolesArray,(item) ->
                return item.bitMask == roleBitMask
            )
    
    
    
    authInstance = {}
    authInstance.passwordreset = (email) ->
      SessionService.passwordreset({email_or_mobile:email})
        
    authInstance.updatepassword = (email,password,token) ->
      SessionService.passwordupdate({email:email,password:password,token:token})
      
    authInstance.signout = ()->
        $rootScope.currentUser =  { username: '', role: userRoles.public }
        $window.sessionStorage.user = angular.toJson($rootScope.currentUser)
        #value = angular.toJson($rootScope.currentUser)
        #document.cookie = escape('user') + '=' + escape(value) + ';secure;path="/"'
        #$cookieStore.put('user',$rootScope.currentUser)
        SessionService.delete
    
    
    authInstance.signin = (email,password)->
      deferred = $q.defer()
      SessionService.save({email:email,password:password}
        (response)->
          role = findUserRoleByBitMask(response.role)
          $rootScope.currentUser.username=response.email
          $rootScope.currentUser.firstname=response.firstname
          $rootScope.currentUser.lastname=response.lastname
          $rootScope.currentUser.auth_token=response.auth_token
          $rootScope.currentUser.venue_id=response.venue_id
          $rootScope.currentUser.role=role
          $http.defaults.headers.common['x-auth-token'] = $rootScope.currentUser.auth_token
          $window.sessionStorage.user = angular.toJson($rootScope.currentUser)
          #$cookieStore.put('user',$rootScope.currentUser)
          deferred.resolve(response)
        (response)->
          $http.defaults.headers.common['x-auth-token'] = ''
          deferred.reject(response))
      return deferred.promise
      
    authInstance.authorize = (accessLevel,role) ->
      role = $rootScope.currentUser.role unless role
      return accessLevel.bitMask & role.bitMask
      
    authInstance.isLoggedIn = () ->
      return $rootScope.currentUser.role.title != userRoles.public.title
    authInstance.getCurrentUser = () ->
        $rootScope.currentUser  
    return authInstance     
])

.factory('UserService', [
    '$resource'
    ($resource) ->
        $resource('/v1/users/:verb/:id'
        {}
        new: { method: 'GET', isArray: false, params: {verb:'new' } }  
        getbytoken: { method: 'GET', isArray: false, params: {verb:'getbytoken' } }  
        post: { method: 'POST', isArray: false, params: {  } }  
        put: { method: 'PUT', isArray: false, params: {  } }               
        )
            
])


.factory('VenueService', [
    '$resource'
    ($resource) ->
        $resource('/v1/venues/:verb/:id'
        {}
        new: { method: 'GET', isArray: false, params: {verb:'new' } }
        post: { method: 'POST', isArray: false, params: {  } }  
        put: { method: 'PUT', isArray: false, params: {  } }               
        )
            
])

.factory('ProductService', [
    '$resource'
    ($resource) ->
        $resource('/v1/venues/:venueId/products/:verb/:id'
        {}
        new: { method: 'GET', isArray: false, params: {verb:'new' } } 
        post: { method: 'POST', isArray: false, params: {  } }  
        put: { method: 'PUT', isArray: false, params: {  } }               
        )
            
])

.factory('SessionService', [
    '$resource'
    ($resource) ->
        $resource('/v1/sessions/:verb/:id' 
        {}
        passwordreset:{method:'POST', isArray:false, params: {verb:'passwordreset' } } 
        passwordupdate:{method:'POST', isArray:false, params: {verb:'passwordupdate' } } )
            
])

