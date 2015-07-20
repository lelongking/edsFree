scope = logics.merchantOptions
syncGenderStatus = (switchery, gender) -> switchery.element.click() if switchery.isChecked() isnt gender

lemon.defineHyper Template.merchantAccountOptions,
  helpers:
    profile: -> Session.get("myProfile")
    gender: -> Session.get("merchantAccountOptionsGenderSelection") ? @gender
    showEditCommand: -> Session.get("merchantAccountOptionShowEditCommand")
    showChangePasswordCommand: -> Session.get("merchantAccountOptionChangePasswordCommand")

  rendered: ->
    syncGenderStatus(this.switch.gender, Session.get("myProfile")?.gender ? true)
    @datePicker.$dateOfBirth.datepicker('setDate', Session.get('myProfile')?.dateOfBirth)

  events:
    "change [name='gender']": (event, template) ->
      Session.set("merchantAccountOptionsGenderSelection", event.target.checked)
      logics.merchantOptions.checkUpdateAccountOption(template)

    "change [name='dateOfBirth']": (event, template) -> logics.merchantOptions.checkUpdateAccountOption(template)
    "input .accountProfileOption": (event, template) -> logics.merchantOptions.checkUpdateAccountOption(template)
    "keyup .accountProfileOption": (event, template) -> logics.merchantOptions.updateAccountOption(template) if event.which is 13
    "click .syncAccountProfileEdit": (event, template) -> logics.merchantOptions.updateAccountOption(template)


    "input .accountChangePassword": (event, template) -> logics.merchantOptions.checkAccountChangePassword(template)
    "keyup .accountChangePassword": (event, template) -> logics.merchantOptions.updateAccountOptionChangePassword(template) if event.which is 13
    "click .changeAccountProfilePassword": (event, template) -> logics.merchantOptions.updateAccountOptionChangePassword(template)


