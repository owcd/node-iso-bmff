module.exports =
    ftyp: require './ftyp'
    mdhd: require './mdhd'
    mdia: require './mdia'
    minf: require './minf'
    moof: require './moof'
    moov: require './moov'
    mvex: require './mvex'
    mvhd: require './mvhd'
    stbl: require './stbl'
    tfdt: require './tfdt'
    tfhd: require './tfhd'
    tkhd: require './tkhd'
    traf: require './traf'
    trak: require './trak'
    trex: require './trex'
    trun: require './trun'
    udta: require './udta'
    default:
        decode: (buffer, offset) ->
            buffer
        encode: (data) ->
            data