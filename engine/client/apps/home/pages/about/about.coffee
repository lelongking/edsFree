lemon.defineWidget Template.about,
  created: ->
    Session.set('loginValid', 'invalid')

  rendered: ->
    $("body").css("overflow-y", "scroll")

  destroyed: ->
    $("body").css("overflow-y", "hidden")
    Session.set('loginValid')

  events:
    "click #gotoMerchantButton": ->
      console.log 'goMerchant'
      Router.go('/merchant')
    "click #logoutButton": ->
      console.log 'logOut'
      lemon.logout()

    "click #authButton.valid": (event, template) -> logics.homeHeader.login(event, template)
    "keypress .login-field": (event, template) ->
      $(template.find("#authButton")).click() if event.which is 13 and Session.get('loginValid') is 'valid'

    "input .login-field": (event, template) ->
      $login    = $(template.find("#authAlias"))
      $password = $(template.find("#authSecret"))
      console.log $login.val(), $password.val()
      if $login.val().length > 0 and $password.val().length > 0 and $login.val().indexOf('@') isnt -1
        Session.set('loginValid', 'valid')
      else
        Session.set('loginValid', 'invalid')