tools = require '../tools'
BufferIterator = require '../bufferIterator'

module.exports.decode = (buffer, offset) ->
    # create iterator
    iterator = new BufferIterator buffer

    # basic extract
    data = {} #tools.initBoxData iterator

    # brand and version
    data.majorBrand = iterator.readString 'utf8', 4
    data.minorVersion = iterator.read32()
    data.compatibleBrands = []

    # extract compatible brands
    while iterator.hasMore()
        data.compatibleBrands.push iterator.readString 'utf8', 4

    # return
    data

module.exports.encode = (data) ->
    # create buffer
    buffer = new Buffer 8 + data.compatibleBrands.length * 4

    # iterator
    iterator = new BufferIterator buffer

    # brand and version
    iterator.writeString data.majorBrand, 4
    iterator.write32 data.minorVersion

    # loop brands
    for brand in data.compatibleBrands
        iterator.writeString brand, 4

    # return
    iterator.buffer