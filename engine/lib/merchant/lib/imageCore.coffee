#resizeAndCropCenter = (source, width, height) ->
#  source.resize(width, height, '^')
#        .gravity('Center').crop(width, height)
#        .stream()
#
#avatarStorage = new FS.Store.FileSystem "avatar",
#  path: "/opt/edsUploads/avatar"
#  transformWrite: (fileObj, readStream, writeStream) ->
#    gmSource = gm(readStream, fileObj.name())
#    resizeAndCropCenter(gmSource, '100', '100').pipe(writeStream)
#
#@AvatarImages = new FS.Collection "avatarImages",
#  stores: [avatarStorage]
#  maxSize: 1048576 #1Megabyte
#  allow:
#    contentTypes: ["images/*"]
#    extensions: ["png", "jpg", "jpeg"]

resizeAndCropCenter = (source, width, height) ->
  source.resize(width, height, '^')
  .gravity('Center').crop(width, height)
  .stream()

modelStorage = (model) ->
  new FS.Store.GridFS model,
    transformWrite: (fileObj, readStream, writeStream) ->
      if gm.isAvailable
        gmSource = gm(readStream, fileObj.name())
        resizeAndCropCenter(gmSource, '100', '100').pipe(writeStream)
      else
        readStream.pipe(writeStream)

newFsCollection = (model)->
  new FS.Collection model,
    stores: [modelStorage(model)]
    maxSize: 1048576 #1Megabyte
    allow:
      contentTypes: ["images/*"]
      extensions: ["png", "jpg", "jpeg"]

@AvatarImages   = newFsCollection("avatarImages")
#@CustomerImages = newFsCollection("customerImages")
#@ProductImages  = newFsCollection("productImages")
#@ProviderImages = newFsCollection("providerImages")