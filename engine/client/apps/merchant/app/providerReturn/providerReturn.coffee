scope = logics.providerReturn
Enums = Apps.Merchant.Enums
lemon.defineApp Template.providerReturn,
  helpers:
    allowSuccessReturn: ->
      currentReturnDetails = Session.get('currentProviderReturn')?.details
      currentParentDetails = Session.get('currentReturnParent')

      if currentReturnDetails?.length > 0 and currentParentDetails?.length > 0
        for returnDetail in currentReturnDetails
          currentProductQuality = 0

          for parentDetail in currentParentDetails
            if parentDetail.productUnit is returnDetail.productUnit
              currentProductQuality += parentDetail.basicQualityAvailable

          return 'disabled' if (currentProductQuality - returnDetail.basicQuality) < 0

      else
        return 'disabled'

    availableQuality: -> @basicQualityAvailable/@conversion



  created: ->
    ProviderSearch.search('')
    UnitProductSearch.search('')

  rendered: ->
    if providerReturn = Session.get('currentProviderReturn')
      $(".providerSelect").select2("readonly", false)
      $(".importSelect").select2("readonly", if providerReturn.owner then false else true)
    else
      $(".providerSelect").select2("readonly", true)
      $(".importSelect").select2("readonly", true)


  events:
#    "keyup input[name='searchFilter']": (event, template) ->
#      searchFilter  = template.ui.$searchFilter.val()
#      productSearch = Helpers.Searchify searchFilter
#      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch


    'click .addReturnDetail': (event, template)->
      console.log @
      scope.currentProviderReturn.addReturnDetail(@_id, @productUnit, 1, @price)
      event.stopPropagation()

    "click .returnSubmit": (event, template) ->
      if currentReturn = Session.get('currentProviderReturn')
        providerReturnLists = Return.findNotSubmitOf('provider').fetch()
        if nextRow = providerReturnLists.getNextBy("_id", currentReturn._id)
          Return.setReturnSession(nextRow._id, 'provider')
        else if previousRow = providerReturnLists.getPreviousBy("_id", currentReturn._id)
          Return.setReturnSession(previousRow._id, 'provider')
        else
          Return.setReturnSession(Return.insert(Enums.getValue('OrderTypes', 'provider')), 'provider')

        scope.currentProviderReturn.submitProviderReturn()