btyp = require './btyp'
Long = require 'long'
BufferIterator = require './bufferIterator'

# reads a single box and returns the struct
module.exports.readBox = readBox = (cursor, buffer, offset) ->
    if cursor + 8 < buffer.length
        slice = buffer.slice(cursor, cursor + 8)
        length = slice.readUInt32BE 0
        type = slice.toString('utf8', 4)
        if cursor + length <= buffer.length
            # decode data
            decode = if btyp[type]? then btyp[type].decode else btyp.default.decode
            slice = buffer.slice(cursor + 8, cursor + length)
            data = decode slice, cursor + offset + 8

            # decoded box
            {
                type: type,
                start: cursor + offset,
                end: cursor + offset + length
                length: length
                data: data
                #raw: slice
            }
        else
            null
    else
        null

# reads many boxes as array
module.exports.readBoxes = (cursor, buffer, offset) ->
    # resulting array
    boxes = []

    # loop while data available
    while cursor < buffer.length
        box = readBox cursor, buffer, offset
        if box
            boxes.push box
            cursor += box.length
        else
            break

    # return
    boxes

# read the version and flags from the buffer at cursor
module.exports.initBoxData = (iterator, flags = {}) ->
    # init data
    data = {}
    info = iterator.read32()
    data.version = info >> 24
    data.flags = info & 0x00FFFFFF

    # loop flags
    for key, flag of flags
        data[key] = (data.flags & flag) is flag

    # return the data
    data

# writes a box and outputs its binary buffer
module.exports.writeBox = (box) ->
    # decode data
    encode = if btyp[box.type]? then btyp[box.type].encode else btyp.default.encode
    data = encode box.data

    # verify
    if false and not data.equals(box.raw)
        console.log('output of box', box.type, 'differs from its input')
        console.log(box.raw.toString('hex'), '=>', data.toString('hex'))

    # header
    header = new Buffer 8
    header.writeUInt32BE data.length + 8, 0
    header.write box.type, 4, 4

    # finalize
    Buffer.concat([header, data])

# write the version and flags to a new buffer
module.exports.writeBoxData = (data, length = 0, flags = {}) ->
    # init flags and length
    length = 4 + length

    # create buffer
    buffer = new Buffer length
    buffer.fill 0
    iterator = new BufferIterator buffer

    # loop properties
    for key, flag of flags
        if data[key]? and data[key]
            data.flags |= flag
        else
            data.flags -= data.flags & flag

    # info
    iterator.write32((data.version << 24) + data.flags)

    # return
    iterator

module.exports.children = (box, type) ->
    children = []
    for b in box.data
        children.push b if b.type is type
    children

module.exports.child = (box, type) ->
    for b in box.data
        return b if b.type is type
    null
