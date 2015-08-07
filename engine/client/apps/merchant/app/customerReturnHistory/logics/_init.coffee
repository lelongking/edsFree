logics.orderReturnHistory = {}
Apps.Merchant.orderReturnHistoryInit = []
Apps.Merchant.orderReturnHistoryReactiveRun = []

Apps.Merchant.orderReturnHistoryInit.push (scope) ->

Apps.Merchant.orderReturnHistoryReactiveRun.push (scope) ->
  if Session.get('mySession')
    returnQuery = {_id: Session.get('mySession').currentCustomerReturnHistory}
    scope.currentCustomerReturnHistory = Schema.returns.findOne returnQuery
    Session.set 'currentCustomerReturnHistory', scope.currentCustomerReturnHistory