'use strict';

angular.module('app.ui.services', [])

.factory('uiHelper', [ ->

    # toastr setting.
    toastr.options =
        "closeButton": true
        "positionClass": "toast-bottom-right"
        "timeOut": "3000"

    logIt = (message, type) ->
        toastr[type](message)

    return {
        handleApiError: (scope,response) ->                  
            if response.status == 422
                scope.validation_errors = response.data if typeof response.data == 'string'
                scope.validation_errors = this.formatErrors(response.data) if typeof response.data == 'object' and response.data.length?
            else         
                this.logError(response.statusText)
        formatErrors: (errors) ->  
            errorText = []              
            errorText.push(error) for error in errors
            return errorText
        showSavedSuccess: () ->                  
            this.logSuccess("Information was saved successfully.")
        showDeletedSuccess: () ->                  
            this.logSuccess("Information was delete successfully.")
        log: (message) ->
            logIt(message, 'info')
            # return is needed, otherwise AngularJS will error out 'Referencing a DOM node in Expression', thanks https://groups.google.com/forum/#!topic/angular/bsTbZ86WAY4
            return 

        logWarning: (message) ->
            logIt(message, 'warning')
            return

        logSuccess: (message) ->
            logIt(message, 'success')
            return

        logError: (message) ->
            logIt(message, 'error')
            return
        
         states: [{ name: 'ALABAMA', abbr: 'AL'},
                    { name: 'ALASKA', abbr: 'AK'},
                    { name: 'ARIZONA', abbr: 'AZ'},
                    { name: 'ARKANSAS', abbr: 'AR'},
                    { name: 'CALIFORNIA', abbr: 'CA'},
                    { name: 'COLORADO', abbr: 'CO'},
                    { name: 'CONNECTICUT', abbr: 'CT'},
                    { name: 'DELAWARE', abbr: 'DE'},
                    { name: 'DISTRICT OF COLUMBIA', abbr: 'DC'},
                    { name: 'FLORIDA', abbr: 'FL'},
                    { name: 'GEORGIA', abbr: 'GA'},
                    { name: 'HAWAII', abbr: 'HI'},
                    { name: 'IDAHO', abbr: 'ID'},
                    { name: 'ILLINOIS', abbr: 'IL'},
                    { name: 'INDIANA', abbr: 'IN'},
                    { name: 'IOWA', abbr: 'IA'},
                    { name: 'KANSAS', abbr: 'KS'},
                    { name: 'KENTUCKY', abbr: 'KY'},
                    { name: 'LOUISIANA', abbr: 'LA'},
                    { name: 'MAINE', abbr: 'ME'},
                    { name: 'MARSHALL ISLANDS', abbr: 'MH'},
                    { name: 'MARYLAND', abbr: 'MD'},
                    { name: 'MASSACHUSETTS', abbr: 'MA'},
                    { name: 'MICHIGAN', abbr: 'MI'},
                    { name: 'MINNESOTA', abbr: 'MN'},
                    { name: 'MISSISSIPPI', abbr: 'MS'},
                    { name: 'MISSOURI', abbr: 'MO'},
                    { name: 'MONTANA', abbr: 'MT'},
                    { name: 'NEBRASKA', abbr: 'NE'},
                    { name: 'NEVADA', abbr: 'NV'},
                    { name: 'NEW HAMPSHIRE', abbr: 'NH'},
                    { name: 'NEW JERSEY', abbr: 'NJ'},
                    { name: 'NEW MEXICO', abbr: 'NM'},
                    { name: 'NEW YORK', abbr: 'NY'},
                    { name: 'NORTH CAROLINA', abbr: 'NC'},
                    { name: 'NORTH DAKOTA', abbr: 'ND'},
                    { name: 'OHIO', abbr: 'OH'},
                    { name: 'OKLAHOMA', abbr: 'OK'},
                    { name: 'OREGON', abbr: 'OR'},
                    { name: 'PALAU', abbr: 'PW'},
                    { name: 'PENNSYLVANIA', abbr: 'PA'},
                    { name: 'RHODE ISLAND', abbr: 'RI'},
                    { name: 'SOUTH CAROLINA', abbr: 'SC'},
                    { name: 'SOUTH DAKOTA', abbr: 'SD'},
                    { name: 'TENNESSEE', abbr: 'TN'},
                    { name: 'TEXAS', abbr: 'TX'},
                    { name: 'UTAH', abbr: 'UT'},
                    { name: 'VERMONT', abbr: 'VT'},
                    { name: 'VIRGINIA', abbr: 'VA'},
                    { name: 'WASHINGTON', abbr: 'WA'},
                    { name: 'WEST VIRGINIA', abbr: 'WV'},
                    { name: 'WISCONSIN', abbr: 'WI'},
                    { name: 'WYOMING', abbr: 'WY' }
                ]
    }
])









