Meteor.methods
  orderSubmitted: (orderId)->
    userProfile = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !userProfile

    orderFound = Schema.orders.findOne({_id: orderId, orderType: 0})
    return {valid: false, error: 'order not found!'} if !orderFound

    console.log 'methods', orderFound
    for detail in orderFound.details
      detailIndex = 0; updateQuery = {$inc:{}}
      updateQuery.$inc["qualities.#{detailIndex}.saleQuality"]     = detail.basicQuality
      updateQuery.$inc["qualities.#{detailIndex}.availableQuality"]= -detail.basicQuality
      updateQuery.$inc["qualities.#{detailIndex}.inStockQuality"]  = -detail.basicQuality
      Schema.products.update detail.product, updateQuery

    if orderFound.profiles.paymentsDelivery
      Schema.orders.update orderFound._id, {$set:{orderType: 2}}
    else
      Schema.orders.update orderFound._id, {$set:{orderType: 1}}