module.exports.decode = (buffer, offset) ->
    # init
    data = {}

    # major brand
    data.majorBrand = buffer.toString('utf8', 0, 4)
    data.minorVersion = buffer.readInt32BE 4
    data.compatibleBrands = []

    # extract compatible brands
    cursor = 8
    while cursor < buffer.length
        data.compatibleBrands.push buffer.toString('utf8', cursor, cursor + 4)
        cursor += 4

    # return
    data

module.exports.encode = (data) ->
    # create buffer
    buffer = new Buffer 8 + data.compatibleBrands.length * 4
    buffer.write data.majorBrand, 0, 4
    buffer.writeInt32BE data.minorVersion, 4

    # write compatible brands
    cursor = 8
    for brand in data.compatibleBrands
        buffer.write brand, cursor, 4
        cursor += 4

    # return
    buffer