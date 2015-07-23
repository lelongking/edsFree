logics.orderManager = {}
Apps.Merchant.orderManagerInit = []

Apps.Merchant.orderManagerInit.push (scope) ->
  date = new Date();
  firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
  lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
  Session.set('orderFilterStartDate', firstDay)
  Session.set('orderFilterToDate', lastDay)

logics.orderManager.reactiveRun = ->
  logics.orderManager.availableBills = Schema.orders.find()
  
#  if Session.get('orderFilterStartDate') and Session.get('orderFilterToDate') and Session.get('myProfile')
#    logics.orderManager.availableBills = Sale.findBillDetails(
#      Session.get('orderFilterStartDate'),
#      Session.get('orderFilterToDate'),
#      Session.get('myProfile').currentWarehouse
#    )
#
#  if Session.get('currentBillManagerSale')
#    logics.orderManager.currentSaleDetails = Schema.saleDetails.find {sale: Session.get('currentBillManagerSale')._id}
