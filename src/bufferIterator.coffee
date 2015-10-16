Long = require 'long'

# reader class
module.exports = class BufferIterator

    # construct the iterator
    constructor: (buffer, offset = 0) ->
        @buffer = buffer
        @_cursor = offset

    # skip some bytes
    skip: (bytes) ->
        @_cursor += bytes

    # has more data?
    hasMore: ->
        @_cursor < @buffer.length

    # remaining
    remaining: ->
        @buffer.length - @_cursor

    # read 8 bit int
    read8: ->
        @_cursor += 1
        @buffer.readUInt8 @_cursor - 1

    # read 16 bit int
    read16: ->
        @_cursor += 2
        @buffer.readUInt16BE @_cursor - 2

    # read 32 bit int
    read32: ->
        @_cursor += 4
        @buffer.readUInt32BE @_cursor - 4

    # read 64 bit int
    read64: ->
        @_cursor += 8
        Long.fromBits(@buffer.readUInt32BE(@_cursor - 4), @buffer.readUInt32BE(@_cursor - 8), true)

    # read string
    readString: (type, length) ->
        @_cursor += length
        @buffer.toString type, @_cursor - length, @_cursor

    # read fixed point 88 float
    readFixedPoint88: ->
        @read16() / 256

    # read fixed point 1616 float
    readFixedPoint1616: ->
        @read32() / 65536

    # read iso 639 lang
    readIso639Lang: ->
        num = @read16()
        Buffer buffer = new Buffer(3)
        for i in [2..0]
            buffer[2 - i] = ((num >>> (5 * i)) & 0x1F) + 0x60
        buffer.toString 'utf8'

    # write 8 bit int
    write8: (value) ->
        @_cursor += 1
        @buffer.writeUInt8 value, @_cursor - 1
        @

    # write 16 bit int
    write16: (value) ->
        @_cursor += 2
        @buffer.writeUInt16BE value, @_cursor - 2
        @

    # write 32 bit int
    write32: (value) ->
        @_cursor += 4
        @buffer.writeUInt32BE value, @_cursor - 4
        @

    # write 64 bit int
    write64: (value) ->
        @_cursor += 8
        @buffer.writeUInt32BE value.getHighBitsUnsigned(), @_cursor - 8
        @buffer.writeUInt32BE value.getLowBitsUnsigned(), @_cursor - 4
        @

    # write string
    writeString: (value, length) ->
        @_cursor += length
        @buffer.write value, @_cursor - length, length
        @

    # write fixed point 88 float
    writeFixedPoint88: (value) ->
        @write16 value * 256
        @

    # write fixed point 1616 float
    writeFixedPoint1616: (value) ->
        @write32 value * 65536
        @

    # write iso 639 lang
    writeIso639Lang: (value) ->
        throw new Error "writeIso639Lang: Invalid language code - #{language}" unless value.length is 3
        num = 0
        for i in [0..2]
            charCode = value.charCodeAt(i) - 0x60
            throw new Error "writeIso639Lang: Invalid character - #{language[i]}" if charCode > 0x1F
            num <<= 5
            num |= charCode
        @write16 num
        @