tools = require '../tools'
BufferIterator = require '../bufferIterator'

# element flags
flags =
    'baseDataOffset': 0x01
    'sampleDescriptionIndex': 0x02
    'defaultSampleDuration': 0x08
    'defaultSampleSize': 0x10
    'defaultSampleFlags': 0x20
    'durationIsEmpty': 0x10000

module.exports.decode = (buffer, offset) ->
    # create iterator
    iterator = new BufferIterator buffer

    # basic extract
    data = tools.initBoxData iterator, flags

    # read
    data.trackId = iterator.read32()
    data.baseDataOffset = iterator.read64() if data.baseDataOffset
    data.sampleDescriptionIndex = iterator.read32() if data.sampleDescriptionIndex
    data.defaultSampleDuration = iterator.read32() if data.defaultSampleDuration
    data.defaultSampleSize = iterator.read32() if data.defaultSampleSize
    data.defaultSampleFlags = iterator.read32() if data.defaultSampleFlags

    # cleanup
    for key, flag of flags
        delete data[key] unless data[key]

    # return
    data

module.exports.encode = (data) ->
    # get length
    length = 4
    length += 8 if data.baseDataOffset?
    length += 4 if data.sampleDescriptionIndex?
    length += 4 if data.defaultSampleDuration?
    length += 4 if data.defaultSampleSize?
    length += 4 if data.defaultSampleFlags?

    # iterator
    iterator = tools.writeBoxData data, length, flags

    # write
    iterator.write32 data.trackId
    iterator.write64 data.baseDataOffset if data.baseDataOffset?
    iterator.write32 data.sampleDescriptionIndex if data.sampleDescriptionIndex?
    iterator.write32 data.defaultSampleDuration if data.defaultSampleDuration?
    iterator.write32 data.defaultSampleSize if data.defaultSampleSize?
    iterator.write32 data.defaultSampleFlags if data.defaultSampleFlags?

    # return
    iterator.buffer