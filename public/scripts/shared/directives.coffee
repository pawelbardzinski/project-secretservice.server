'use strict';

angular.module('app.directives', ['app.services'])

.directive('imgHolder', [ ->
    return {
        restrict: 'A'
        link: (scope, ele, attrs) ->
            Holder.run(
                images: ele[0]
            )
    }
])


# add class for specific pages
.directive('customPage', () ->
    return {
        restrict: "A"
        controller: [
            '$scope', '$element', '$location'
            ($scope, $element, $location) ->
                path = ->
                    return $location.path()

                addBg = (path) ->
                    # remove all the classes
                    $element.removeClass('body-wide body-lock')
                    length = path.length
                    path = path.substring(0,path.length - 1) if path.lastIndexOf('/') == (length - 1)
                    # add certain class based on path
                    switch path
                        when '/404', '/system/404', '/system/500', '/signin','/system/signin',  '/system/signup', '/forgot-password', '/resetpassword' , '/resetpassword' then $element.addClass('body-wide')
                        when path.indexOf('/resetpassword') > -1 then $element.addClass('body-wide')
                        when '/pages/lock-screen' then $element.addClass('body-wide body-lock')
                    $element.addClass('body-wide') if path.indexOf('/resetpassword') > -1
                addBg( $location.path() )

                $scope.$watch(path, (newVal, oldVal) ->
                    if newVal is oldVal
                        return
                    addBg($location.path())
                )
        ]
    }
)

# switch stylesheet file
.directive('uiColorSwitch', [ ->
    return {
        restrict: 'A'
        link: (scope, ele, attrs) ->
            ele.find('.color-option').on('click', (event)->
                $this = $(this)
                hrefUrl = undefined

                style = $this.data('style')
                if style is 'loulou'
                    hrefUrl = 'styles/main.css'
                    $('link[href^="styles/main"]').attr('href',hrefUrl)
                else if style
                    style = '-' + style
                    hrefUrl = 'styles/main' + style + '.css'
                    $('link[href^="styles/main"]').attr('href',hrefUrl)
                else
                    return false

                event.preventDefault()
            )
    }
])


# history back button
.directive('goBack', [ ->
    return {
        restrict: "A"
        controller: [
            '$scope', '$element', '$window'
            ($scope, $element, $window) ->
                $element.on('click', ->
                    $window.history.back()
                )
        ]
    }
])

.directive('accessLevel', ['Auth', (Auth) ->
    return {
        restrict: 'A',
        link: ($scope, element, attrs) ->
            prevDisp = element.css('display')
            accessLevel=null

            $scope.$watch('currentUser', (currentUser) ->
                updateCSS()
            , true)

            attrs.$observe('accessLevel', (al) ->
                if(al) 
                    accessLevel = $scope.$eval(al)
                updateCSS()
            )

            updateCSS = () ->
                userRole = Auth.getCurrentUser().role
                if(userRole) 
                    if(!Auth.authorize(accessLevel, userRole))
                        element.css('display', 'none')
                    else
                        element.css('display', prevDisp)               
            
        
    }
])
