lemon.defineWidget Template.messageNotifications,
  helpers:
    topMessages: -> logics.merchantNotification.topMessages
    hasRead: -> if _.contains(@reads, Meteor.userId()) then '' else 'unread'
  events:
    "mouseleave li.message": (event, template) -> Messenger.read(@_id) unless _.contains(@reads, Meteor.userId())

