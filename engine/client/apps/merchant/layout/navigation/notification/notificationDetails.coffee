lemon.defineWidget Template.notificationDetails,
  helpers:
    notifies: -> logics.merchantNotification.notifies
    unreadNotifies: -> logics.merchantNotification.unreadNotifies
    hasRead: -> if _.contains(@reads, Meteor.userId()) then '' else 'unread'

  events:
    "mouseleave li.notification": (event, template) -> Notification.read(@_id) unless _.contains(@reads, Meteor.userId())

