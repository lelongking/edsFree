waiting           = {'deliveries.status': 1}
delivering        = {'deliveries.status': {$in: [2]}}
done              = {'deliveries.status': {$in: [3,4]}}
sortByUpdateDesc  = {sort: {'version.createdAt': -1}}

Apps.Merchant.deliveryInit.push (scope) ->
  belongedToThisMerchant     = {merchant: Session.get('merchant')._id, 'profiles.paymentsDelivery': 1}
  scope.waitingDeliveries    = Schema.orders.find({$and: [belongedToThisMerchant, waiting]}, sortByUpdateDesc)
  scope.deliveringDeliveries = Schema.orders.find({$and: [belongedToThisMerchant, delivering]}, sortByUpdateDesc)
  scope.doneDeliveries       = Schema.orders.find({$and: [belongedToThisMerchant, done]}, sortByUpdateDesc)