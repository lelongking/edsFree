scope = logics.messenger

lemon.defineWidget Template.messenger,
  helpers:
    currentMessages: ->
      if Session.get('currentChatTarget')
        scope.messengerDeps?.depend()
        scope.currentMessages

    messageClass: -> if @sender is Meteor.userId() then 'me' else 'friend'
    firstName: ->
      if user = Meteor.users.findOne(Session.get('currentChatTarget'))
        Helpers.firstName(user.profile?.name ? user.emails[0].address)

    avatarUrl: ->
      if user = Meteor.users.findOne(Session.get('currentChatTarget'))
        if user.profile.image then AvatarImages.findOne(user.profile.image)?.url() else undefined

    friendMessage: -> @sender isnt Meteor.userId()
    hasTarget: -> Session.get('currentChatTarget') isnt undefined

    targetName: ->
      if user = Meteor.users.findOne(Session.get('currentChatTarget'))
        user.profile?.name ? user.emails[0].address

  created: -> Apps.setup(scope, Apps.Merchant.messengerInit, 'messenger')

  rendered: ->
    scope.thisTime = Date.now()

    scope.messengerDeps = new Tracker.Dependency

    scope.initTracker = Tracker.autorun ->
      Apps.setup(scope, Apps.Merchant.messengerReactive)

    scope.incomingObserver = scope.allMessages.observeChanges
      added: (id, instance) ->
        scope.playSoundIfNecessary(instance, scope.thisTime)

    $(".conversation-wrapper").slimScroll({size: '3px', color: '#909090', railOpacity: 1})
    $("body").on "DOMNodeInserted", ".conversation-wrapper", (e) ->
      $(".conversation-wrapper").slimScroll({scrollTo: '99999px'})

  destroyed: ->
    scope.initTracker.stop()
    scope.incomingObserver.stop()
    $("body").off("DOMNodeInserted")

  events:
    "keypress .input-wrapper input": ->
      $element = $(event.target)
      message = $element.val()
      if event.which is 13 and message.length > 0 and Session.get('currentChatTarget')
        Messenger.say message, Session.get('currentChatTarget')
        $element.val('')