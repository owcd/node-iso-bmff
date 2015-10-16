tools = require '../tools'
BufferIterator = require '../bufferIterator'

module.exports.decode = (buffer, offset) ->
    # create iterator
    iterator = new BufferIterator buffer

    # basic extract
    data = tools.initBoxData iterator

    # read
    data.trackId = iterator.read32()
    data.defaultSampleDescriptionIndex = iterator.read32()
    data.defaultSampleDuration = iterator.read32()
    data.defaultSampleSize = iterator.read32()
    data.defaultSampleFlags = iterator.read32()

    # return
    data

module.exports.encode = (data) ->
    # iterator
    iterator = tools.writeBoxData data, 20

    # write
    iterator.write32 data.trackId
    iterator.write32 data.defaultSampleDescriptionIndex
    iterator.write32 data.defaultSampleDuration
    iterator.write32 data.defaultSampleSize
    iterator.write32 data.defaultSampleFlags

    # return
    iterator.buffer