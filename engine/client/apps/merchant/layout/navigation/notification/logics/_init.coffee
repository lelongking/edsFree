notification = logics.merchantNotification = {}

sentByMe = {sender: Meteor.userId()}
sendToMe = {receiver: Meteor.userId()}
unread   = {reads: {$ne: Meteor.userId()}}

notification.notifies = Schema.notifications.find({ isRequest: false }, {sort: {'version.createdAt': -1}, limit: 10})
notification.unreadNotifies = Schema.notifications.find({ isRequest: false, reads: {$ne: Meteor.userId()} })
#notification.unreadNotifies = Schema.notifications.find({ isRequest: false, reads: {$ne: Meteor.userId()} })

notification.myNotifies = Schema.notifications.find({receiver: Meteor.userId()}, {sort: {'version.createdAt': -1}, limit: 10})

notification.requests = Schema.notifications.find { isRequest: true }, {sort: {'version.createdAt': -1}}
notification.unreadRequests = Schema.notifications.find { isRequest: true, seen: false }

notification.topMessages = Schema.messages.find { $or: [sendToMe] }, {sort: {'version.createdAt': -1}, limit: 10}
notification.unreadMessages = Schema.messages.find { $and: [sendToMe, unread] }