lemon.defineWidget Template.chatAvatarItem,
  helpers:
    alias: ->
      alias =
        if @profile and @profile.name then @profile.name
        else Meteor.users.findOne(@_id)?.emails[0].address
      return {
        shortName: Helpers.shortName(alias)
        firstName: Helpers.firstName(alias)
      }
    avatarUrl: -> if @profile and @profile.image then AvatarImages.findOne(@profile.image)?.url() else undefined

    hasUnreadMessage: ->
      return '' if @user is Meteor.userId()
      result = Schema.messages.findOne { $and: [{sender: @user}, {reads: {$ne: Meteor.userId()}}] }
      if result then 'active' else ''