tools = require '../tools'
BufferIterator = require '../bufferIterator'

# element properties
flags =
    'enabled': 0x01
    'inMovie': 0x02
    'inPreview': 0x04

module.exports.decode = (buffer, offset) ->
    # create iterator
    iterator = new BufferIterator buffer

    # basic extract
    data = tools.initBoxData iterator, flags

    # default readData
    readData = -> if data.version is 1 then iterator.read64() else iterator.read32()

    # read properties
    data.creationTime = readData()
    data.modificationTime = readData()
    data.trackId = iterator.read32()
    iterator.skip 4
    data.duration = readData()
    iterator.skip 8
    data.layer = iterator.read16()
    data.alternateGroup = iterator.read16()
    data.volume = iterator.readFixedPoint88()

    # extract matrix
    data.matrix = []
    for i in [0..8]
        data.matrix.push iterator.read32()

    # size
    data.width = iterator.read32()
    data.height = iterator.read32()

    # data
    data

module.exports.encode = (data) ->
    # compute length
    length = 80
    length += 12 if data.version is 1

    # iterator
    iterator = tools.writeBoxData data, length, flags

    # default writeData
    writeData = (value) -> if data.version is 1 then iterator.write64(value) else iterator.write32(value)

    # write properties
    writeData data.creationTime
    writeData data.modificationTime
    iterator.write32 data.trackId
    iterator.skip 4
    writeData data.duration
    iterator.skip 8
    iterator.write16 data.layer
    iterator.write16 data.alternateGroup
    iterator.writeFixedPoint88 data.volume

    # write matrix
    for i in [0..8]
        iterator.write32 data.matrix[i]

    # size
    iterator.write32 data.width
    iterator.write32 data.height

    # return
    iterator.buffer