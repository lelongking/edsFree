Schema.add 'messages', "Messenger", class Messenger
  @say: (message, receiver) ->
    @schema.insert
      sender: Meteor.userId()
      receiver: receiver
      message: message

  @read: (messageId) ->
    currentMessage = @schema.findOne(messageId)
    @schema.update(messageId, {$push: {reads: Meteor.userId()}}) if currentMessage and !_.contains(currentMessage.reads ? [], Meteor.userId())