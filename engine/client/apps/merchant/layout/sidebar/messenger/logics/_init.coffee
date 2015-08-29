logics.messenger = { }
Apps.Merchant.messengerInit = []
Apps.Merchant.messengerReactive = []

Apps.Merchant.messengerReactive.push (scope) ->
  if target = Session.get('currentChatTarget')
    scope.messengerDeps.changed()
    scope.thisTime = new Date()
    Meteor.subscribe("conversationWith", target)
    sentByTarget = { sender: target }
    sentToTarget = { receiver: target }
    scope.currentMessages = Schema.messages.find {$or: [sentByTarget, sentToTarget]}, {sort: {"version.createdAt": 1}}