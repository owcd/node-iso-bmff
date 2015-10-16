tools = require '../tools'
BufferIterator = require '../bufferIterator'

module.exports.decode = (buffer, offset) ->
    # create iterator
    iterator = new BufferIterator buffer

    # basic extract
    data = tools.initBoxData iterator

    # default readData
    readData = -> if data.version is 1 then iterator.read64() else iterator.read32()

    # read properties
    data.creationTime = readData()
    data.modificationTime = readData()
    data.timeScale = iterator.read32()
    data.duration = readData()
    data.rate = iterator.readFixedPoint1616()
    data.volume = iterator.readFixedPoint88()

    # reserved
    iterator.skip 10

    # extract matrix
    data.matrix = []
    for i in [0..8]
        data.matrix.push iterator.read32()

    # reserved
    iterator.skip 24

    # track id
    data.nextTrackId = iterator.read32()

    # data
    data

module.exports.encode = (data) ->
    # compute length
    length = 96
    length += 12 if data.version is 1

    # iterator
    iterator = tools.writeBoxData data, length

    # default writeData
    writeData = (value) -> if data.version is 1 then iterator.write64(value) else iterator.write32(value)

    # write properties
    writeData data.creationTime
    writeData data.modificationTime
    iterator.write32 data.timeScale
    writeData data.duration
    iterator.writeFixedPoint1616 data.rate
    iterator.writeFixedPoint88 data.volume

    # reserved
    iterator.skip 10

    # write matrix
    for i in [0..8]
        iterator.write32 data.matrix[i]

    # reserved
    iterator.skip 24

    # next track
    iterator.write32 data.nextTrackId

    # return
    iterator.buffer
