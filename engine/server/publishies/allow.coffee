allowModifies = (userId, currentRole) ->
  currentProfile = Schema.userProfiles.findOne({user: userId})
  return false if !currentProfile or !currentRole.parent
  currentProfile.parentMerchant is currentRole.parent

Schema.roles.allow
  insert: (userId, currentRole) -> allowModifies(userId, currentRole)
  update: (userId, currentRole) -> allowModifies(userId, currentRole)
  remove: (userId, currentRole) -> allowModifies(userId, currentRole)


Meteor.publish 'fake', ->
  self = @
  setTimeout ->
    self.ready()
  , 20000

Meteor.publish 'system', -> Schema.systems.find {}
Schema.systems.allow
  insert: -> true
  update: -> true
  remove: -> true

AvatarImages.allow
  insert: -> true
  update: -> true
  remove: -> true
  download: -> true


Meteor.publish "conversationWith", (targetId) ->
  sentToTargets =  { sender: @userId, receiver: targetId }
  sentByTargets =  { sender: targetId, receiver: @userId }
  Schema.messages.find {$or: [sentToTargets, sentByTargets]}

Meteor.publish 'unreadMessages', ->
  return [] if !@userId
  Schema.messages.find {receiver: @userId, reads: {$ne: @userId}}
Schema.messages.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.users.allow
  insert: (userId, user)-> true
  update: (userId, user)-> true
  remove: (userId, user)-> true

Meteor.publish 'unreadNotifications', ->
  return [] if !@userId
  Schema.notifications.find {receiver: @userId, seen: false}
Schema.notifications.allow
  insert: -> true
  update: -> true
  remove: -> true

#-----------------------------------------------------------------------------------------------------------------------
Schema.merchants.allow
  insert: -> true
  update: -> true
  remove: -> true

#Schema.warehouses.allow
#  insert: -> true
#  update: -> true
#  remove: -> true
#
#Schema.skulls.allow
#  insert: -> true
#  update: -> true
#  remove: -> true
#
Schema.products.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.productGroups.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.priceBooks.allow
  insert: -> true
  update: -> true
  remove: -> true


#-----------------------------------------------------------------------------------------------------------------------
Schema.customers.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.customerGroups.allow
  insert: -> true
  update: -> true
  remove: -> true

#Schema.partners.allow
#  insert: -> true
#  update: -> true
#  remove: -> true

Schema.providers.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.orders.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.imports.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.returns.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.inventories.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.transactions.allow
  insert: -> true
  update: -> true
  remove: -> true