lemon.defineWidget Template.myNotificationDetails,
  helpers:
    notifies: -> logics.merchantNotification.myNotifies
    unreadNotifies: -> logics.merchantNotification.unreadNotifies