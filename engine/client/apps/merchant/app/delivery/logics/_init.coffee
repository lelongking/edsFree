logics.delivery = {}
Apps.Merchant.deliveryInit = []

Apps.Merchant.deliveryInit.push (scope) ->
  Session.setDefault('deliveryFilter', 'working')