Meteor.startup ->
  moment.locale('vi')
  Router.configure
    progressDebug: false

  Tracker.autorun ->
    if Meteor.userId()
      user = Meteor.user()
      Session.set 'myProfile', user.profiles
      Session.set 'mySession', user.sessions
      Session.set 'merchant', Schema.merchants.findOne(user.profiles?.merchant)