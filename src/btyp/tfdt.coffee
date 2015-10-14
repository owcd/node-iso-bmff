Long = require 'long'

module.exports.decode = (buffer, offset) ->
    data = {}

    # basic info
    info = buffer.readUInt32BE 0
    data.version = info >> 24
    data.flags = info & 0x00FFFFFF

    # 4 or 8 bytes
    if data.version is 1
        data.baseMediaDecodeTime = Long.fromBits(buffer.readUInt32BE(8), buffer.readUInt32BE(4), true)
    else
        data.baseMediaDecodeTime = buffer.readUInt32BE 4

    # return
    data

module.exports.encode = (data) ->
    # determine length
    length = 8
    length += 4 if data.version is 1

    # create buffer
    buffer = new Buffer length

    # info
    info = (data.version << 24) + data.flags
    buffer.writeUInt32BE info

    # 4 or 8 bytes
    if data.version is 1
        buffer.writeUInt32BE data.baseMediaDecodeTime.getHighBitsUnsigned(), 4
        buffer.writeUInt32BE data.baseMediaDecodeTime.getLowBitsUnsigned(), 8
    else
        buffer.writeUInt32BE 4, data.baseMediaDecodeTime

    # return
    buffer