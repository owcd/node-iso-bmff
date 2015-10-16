tools = require '../tools'
BufferIterator = require '../bufferIterator'

module.exports.decode = (buffer, offset) ->
    # create iterator
    iterator = new BufferIterator buffer

    # basic extract
    data = tools.initBoxData iterator

    # default readData
    readData = -> if data.version is 1 then iterator.read64() else iterator.read32()

    # properties
    data.creationTime = readData()
    data.modificationTime = readData()
    data.timeScale = iterator.read32()
    data.duration = readData()
    data.language = iterator.readIso639Lang()

    # data
    data

module.exports.encode = (data) ->
    # compute length
    length = 20
    length += 12 if data.version is 1

    # write box data
    iterator = tools.writeBoxData data, length

    # default writeData
    writeData = (value) -> if data.version is 1 then iterator.write64(value) else iterator.write32(value)

    # write properties
    writeData data.creationTime
    writeData data.modificationTime
    iterator.write32 data.timeScale
    writeData data.duration
    iterator.writeIso639Lang data.language

    # return
    iterator.buffer