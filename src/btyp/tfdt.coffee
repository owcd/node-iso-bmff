tools = require '../tools'
BufferIterator = require '../bufferIterator'

module.exports.decode = (buffer, offset) ->
    # create iterator
    iterator = new BufferIterator buffer

    # basic extract
    data = tools.initBoxData iterator

    # switch by version
    if data.version is 1
        data.baseMediaDecodeTime = iterator.read64()
    else
        data.baseMediaDecodeTime = iterator.read32()

    # return
    data

module.exports.encode = (data) ->
    # determine length
    length = 4
    length += 4 if data.version is 1

    # iterator
    iterator = tools.writeBoxData data, length

    # 4 or 8 bytes
    if data.version is 1
        iterator.write64 data.baseMediaDecodeTime
    else
        iterator.write32 data.baseMediaDecodeTime

    # return
    iterator.buffer