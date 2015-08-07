logics.providerReturnHistory = {}
Apps.Merchant.providerReturnHistoryInit = []
Apps.Merchant.providerReturnHistoryReactiveRun = []

Apps.Merchant.providerReturnHistoryInit.push (scope) ->

Apps.Merchant.providerReturnHistoryReactiveRun.push (scope) ->
  if Session.get('mySession')
    returnQuery = {_id: Session.get('mySession').currentProviderReturnHistory}
    scope.currentProviderReturnHistory = Schema.returns.findOne returnQuery
    Session.set 'currentProviderReturnHistory', scope.currentProviderReturnHistory