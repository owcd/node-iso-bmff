tools = require '../tools'
BufferIterator = require '../bufferIterator'

# element flags
flags =
    'dataOffset': 0x01
    'firstSampleFlags': 0x04
    'sampleDuration': 0x100
    'sampleSize': 0x200
    'sampleFlags': 0x400
    'sampleCompositionTimeOffset': 0x800

sampleFlags = ['sampleDuration', 'sampleSize', 'sampleFlags', 'sampleCompositionTimeOffset']

module.exports.decode = (buffer, offset) ->
    # create iterator
    iterator = new BufferIterator buffer

    # basic extract
    data = tools.initBoxData iterator, flags

    # read
    data.sampleCount = iterator.read32()
    data.dataOffset = iterator.read32() if data.dataOffset
    data.firstSampleFlags = iterator.read32() if data.firstSampleFlags

    # loop samples
    data.samples = []
    for i in [0..data.sampleCount - 1]
        sample = {}
        sample.sampleDuration = iterator.read32() if data.sampleDuration
        sample.sampleSize = iterator.read32() if data.sampleSize
        sample.sampleFlags = iterator.read32() if data.sampleFlags
        sample.sampleCompositionTimeOffset = iterator.read32() if data.sampleCompositionTimeOffset
        data.samples.push sample

    # cleanup
    for key, flag of flags
        if key in sampleFlags
            delete data[key]
        else unless data[key]
            delete data[key]

    # return
    data

module.exports.encode = (data) ->
    # reset (sub-) sample flags
    for key in sampleFlags
        data[key] = false

    # loop samples to determine enabled flags
    sampleLength = 0
    for sample in data.samples
        for key in sampleFlags
            if sample[key]? and not data[key]
                sampleLength += 4
                data[key] = true

    # get length
    length = 4
    length += 4 if data.dataOffset?
    length += 4 if data.firstSampleFlags?

    # iterator
    iterator = tools.writeBoxData data, length + sampleLength * data.samples.length, flags

    # write
    iterator.write32 data.samples.length
    iterator.write32 data.dataOffset if data.dataOffset?
    iterator.write32 data.firstSampleFlags if data.firstSampleFlags?

    # loop samples
    for sample in data.samples
        iterator.write32 sample.sampleDuration if data.sampleDuration
        iterator.write32 sample.sampleSize if data.sampleSize
        iterator.write32 sample.sampleFlags if data.sampleFlags
        iterator.write32 sample.sampleCompositionTimeOffset if data.sampleCompositionTimeOffset

    # return
    iterator.buffer