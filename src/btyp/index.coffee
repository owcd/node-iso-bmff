module.exports =
    ftyp: require './ftyp'
    mdia: require './mdia'
    minf: require './minf'
    moof: require './moof'
    moov: require './moov'
    mvex: require './mvex'
    stbl: require './stbl'
    tfdt: require './tfdt'
    tfhd: require './tfhd'
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