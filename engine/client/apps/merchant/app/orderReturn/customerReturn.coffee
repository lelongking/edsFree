scope = logics.customerReturn

lemon.defineApp Template.customerReturn,
  helpers:
    allowSuccessReturn: -> if Session.get('currentCustomerReturn')?.owner then '' else 'disabled'

  created: ->
    CustomerSearch.search('')
    UnitProductSearch.search('')
#    lemon.dependencies.resolve('customerReturn')

#  rendered: ->
#    if customer = Session.get('customerReturnCurrentCustomer')
#      Meteor.subscribe('customerReturnProductData', customer._id)

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      searchFilter  = template.ui.$searchFilter.val()
      productSearch = Helpers.Searchify searchFilter
      if event.which is 17 then console.log 'up' else UnitProductSearch.search productSearch


    'click .addReturnDetail': (event, template)->
      scope.currentCustomerReturn.addReturnDetail(@_id)
      event.stopPropagation()

    "click .returnSubmit": (event, template) ->
      if currentReturn = Session.get('currentCustomerReturn')
        customerReturnLists = Return.findNotSubmitOf('customer').fetch()
        if nextRow = customerReturnLists.getNextBy("_id", currentReturn._id)
          Return.setReturnSession(nextRow._id, 'customer')
        else if previousRow = customerReturnLists.getPreviousBy("_id", currentReturn._id)
          Return.setReturnSession(previousRow._id, 'customer')
        else
          Return.setReturnSession(Return.insert(), 'customer')

        scope.currentCustomerReturn.returnSubmit()