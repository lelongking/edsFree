Apps.Merchant.transactionInit.push (scope) ->
  transactionMenus = scope.transactionMenus = [
    display: "khách hàng"
    icon: "pomegranate icon-users-outline"
    app: "merchantOptions"
  ,
    display: "nhà cung cấp"
    icon: "carrot icon-location-1"
    app: "staffManagement"
  ]
