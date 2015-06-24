logics.customerReturn = {}
Apps.Merchant.customerReturnInit = []
Apps.Merchant.customerReturnReactiveRun = []

Apps.Merchant.customerReturnReactiveRun.push (scope) ->
  if Session.get('mySession')
    scope.currentCustomerReturn = Schema.returns.findOne Session.get('mySession').currentCustomerReturn
    Session.set 'currentCustomerReturn', scope.currentCustomerReturn

  if newOwnerId = Session.get('currentCustomerReturn')?.owner
    if !(oldOwnerId = Session.get('currentOwner')?._id) or oldOwnerId isnt newOwnerId
      Session.set('currentCustomerReturn', Schema.returns.findOne newOwnerId)
  else
    Session.set 'currentCustomerReturn'

Apps.Merchant.customerReturnInit.push (scope) ->
  scope.tabOptions =
    source: Return.findNotSubmitOf('customer')
    currentSource: 'currentCustomerReturn'
    caption: 'returnName'
    key: '_id'
    createAction  : -> Return.insert('customer')
    destroyAction : (instance) -> if instance then instance.remove(); Return.findNotSubmitOf('customer').count() else -1
    navigateAction: (instance) -> Return.setReturnSession(instance._id)
