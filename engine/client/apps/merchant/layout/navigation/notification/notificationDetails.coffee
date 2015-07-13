lemon.defineWidget Template.notificationDetails,
  helpers:
    notifies: -> logics.merchantNotification.notifies
    unreadNotifies: -> logics.merchantNotification.unreadNotifies