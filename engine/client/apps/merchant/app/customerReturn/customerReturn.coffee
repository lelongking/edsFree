scope = logics.customerReturn
Enums = Apps.Merchant.Enums
lemon.defineApp Template.customerReturn,
  helpers:
    allowSuccessReturn: ->
      currentReturnDetails = Session.get('currentCustomerReturn')?.details
      currentParentDetails = Session.get('currentReturnParent')

      if currentReturnDetails?.length > 0 and currentParentDetails?.length > 0
        for returnDetail in currentReturnDetails
          currentProductQuality = 0

          for parentDetail in currentParentDetails
            if parentDetail.productUnit is returnDetail.productUnit
              currentProductQuality += parentDetail.basicQuality

              if parentDetail.return?.length > 0
                (currentProductQuality -= item.basicQuality) for item in parentDetail.return

          return 'disabled' if (currentProductQuality - returnDetail.basicQuality) < 0

      else
        return 'disabled'

    availableQuality: -> @basicQualityAvailable/@conversion

  created: ->
    CustomerSearch.search('')
    UnitProductSearch.search('')

  rendered: ->
    if customerReturn = Session.get('currentCustomerReturn')
      $(".customerSelect").select2("readonly", false)
      $(".orderSelect").select2("readonly", if customerReturn.owner then false else true)
    else
      $(".customerSelect").select2("readonly", true)
      $(".orderSelect").select2("readonly", true)


  events:
#    "keyup input[name='searchFilter']": (event, template) ->
#      searchFilter  = template.ui.$searchFilter.val()
#      productSearch = Helpers.Searchify searchFilter
#      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch


    'click .addReturnDetail': (event, template)->
      scope.currentCustomerReturn.addReturnDetail(@_id, @productUnit, 1, @price)
      event.stopPropagation()

    "click .returnSubmit": (event, template) ->
      if currentReturn = Session.get('currentCustomerReturn')
        customerReturnLists = Return.findNotSubmitOf('customer').fetch()
        if nextRow = customerReturnLists.getNextBy("_id", currentReturn._id)
          Return.setReturnSession(nextRow._id, 'customer')
        else if previousRow = customerReturnLists.getPreviousBy("_id", currentReturn._id)
          Return.setReturnSession(previousRow._id, 'customer')
        else
          Return.setReturnSession(Return.insert(Enums.getValue('OrderTypes', 'customer')), 'customer')

        scope.currentCustomerReturn.submitCustomerReturn()