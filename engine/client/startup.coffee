Meteor.startup ->
  moment.locale('vi')
  Router.configure
    progressDebug: false

  Meteor.call('trackingProduct')

  Tracker.autorun ->
    if Meteor.userId()
      user = Meteor.users.findOne(Meteor.userId())
      user.profile._id = user._id
      Session.set 'myProfile', user.profile
      user.sessions._id = user._id
      Session.set 'mySession', user.sessions
      Session.set 'merchant', Schema.merchants.findOne(user.profile?.merchant)
      Session.set 'priceBookBasic', Schema.priceBooks.findOne({priceBookType: 0, merchant: user.profile?.merchant})