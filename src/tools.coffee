btyp = require './btyp'
Long = require 'long'

# reads a single box and returns the struct
module.exports.readBox = readBox = (cursor, buffer, offset) ->
    if cursor + 8 < buffer.length
        slice = buffer.slice(cursor, cursor + 8)
        length = slice.readUInt32BE 0
        type = slice.toString('utf8', 4)
        if cursor + length <= buffer.length
            #console.log 'box', type, length

            # decode data
            decode = if btyp[type]? then btyp[type].decode else btyp.default.decode
            data = decode buffer.slice(cursor + 8, cursor + length), cursor + offset + 8

            # decoded box
            {
                type: type,
                start: cursor + offset,
                end: cursor + offset + length
                length: length
                data: data
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

# read the properties
readProperties = (buffer, properties, cursor, data) ->
    # loop properties
    for key, property of properties
        if typeof property.type is 'object'
            data[key] = []
            for i in [0..data[property.ref] - 1]
                element =
                    flags: data.flags
                cursor = readProperties buffer, property.type, cursor, element
                delete element.flags
                data[key].push element
        else if property.type is 'boolean'
            data[key] = data.flags & property.flag is property.flag
        else if not property.flag? or (data.flags & property.flag) is property.flag
            if property.type is 'long'
                data[key] = Long.fromBits(buffer.readUInt32BE(cursor + 4), buffer.readUInt32BE(cursor), true)
                cursor += 8
            else if property.type is 'number'
                data[key] = buffer.readUInt32BE cursor
                cursor += 4
            else
                throw new Error("unsupported type #{property.type}")

    # current cursor position
    cursor

# read the version and flags from the buffer at cursor
module.exports.readBoxProperties = (buffer, properties, cursor = 0) ->
    # init data
    data = {}
    info = buffer.readUInt32BE cursor
    data.version = info >> 24
    data.flags = info & 0x00FFFFFF
    cursor += 4

    # read the properties
    readProperties buffer, properties, cursor, data, data.flags

    # return the data
    data

# writes a box and outputs its binary buffer
module.exports.writeBox = (box) ->
    # decode data
    encode = if btyp[box.type]? then btyp[box.type].encode else btyp.default.encode
    data = encode box.data

    # header
    header = new Buffer 8
    header.writeUInt32BE data.length + 8, 0
    header.write box.type, 4, 4

    # finalize
    Buffer.concat([header, data])

# determine box property length and set flags
determineBoxPropertyLength = (data, properties) ->
    length = 0

    # loop properties
    for key, property of properties
        if typeof property.type is 'object'
            # make sure ref value is correct
            data[property.ref] = data[key].length
            for i in [0..data[property.ref] - 1]
                data[key][i].flags = 0
                length += determineBoxPropertyLength data[key][i], property.type
                data.flags |= data[key][i].flags
        else if property.type is 'boolean'
            if data[key]? and data[key]
                data.flags |= property.flag
            else
                data.flags -= data.flags & property.flag
        else if data[key]?
            data.flags |= property.flag if property.flag?
            if property.type is 'long'
                length += 8
            else if property.type is 'number'
                length += 4
            else
                throw new Error("unsupported type #{property.type}")
        else
            data.flags -= data.flags & property.flag

    # length
    length

# write the properties of the box
writeProperties = (data, properties, buffer, cursor) ->
    # loop properties
    for key, property of properties
        continue unless data[key]?
        if typeof property.type is 'object'
            for i in [0..data[property.ref] - 1]
                cursor = writeProperties data[key][i], property.type, buffer, cursor
        else if property.type is 'long'
            buffer.writeUInt32BE data[key].getHighBitsUnsigned(), cursor
            buffer.writeUInt32BE data[key].getLowBitsUnsigned(), cursor + 4
            cursor += 8
        else if property.type is 'number'
            buffer.writeUInt32BE data[key], cursor
            cursor += 4

    cursor

# write the version and flags to a new buffer
module.exports.writeBoxProperties = (data, properties) ->
    # init flags and length
    length = 4 + determineBoxPropertyLength(data, properties)

    # create buffer
    buffer = new Buffer length

    # info
    info = (data.version << 24) + data.flags
    buffer.writeUInt32BE info

    # write properties
    writeProperties data, properties, buffer, 4

    # return
    buffer