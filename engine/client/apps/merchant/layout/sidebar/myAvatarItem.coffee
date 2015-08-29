lemon.defineWidget Template.myAvatarItem,
  helpers:
    alias: ->
      alias = @name ? Meteor.users.findOne(@_id)?.emails[0].address
      return {
        shortName: Helpers.shortName(alias)
        firstName: Helpers.firstName(alias)
      }
    avatarUrl: -> if @image then AvatarImages.findOne(@image)?.url() else undefined

  events:
    "click .avatar": (event, template) -> template.find('.avatarFileSelector').click()
    "change .avatarFileSelector": (event, template)->
      instance = Session.get('myProfile')
      files = event.target.files
      if files.length > 0
        AvatarImages.insert files[0], (error, fileObj) ->
          if error
            console.log 'avatar image upload error', error
          else
            AvatarImages.findOne(instance.image)?.remove()
            console.log 'before error'
            Meteor.users.update instance._id, $set: {"profile.image": fileObj._id}
            console.log 'done'
