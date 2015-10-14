tools = require '../tools'

# element properties
properties =
    'trackId':
        'type': 'number'
    'baseDataOffset':
        'type': 'long'
        'flag': 0x01
    'sampleDescriptionIndex':
        'type': 'number'
        'flag': 0x02
    'defaultSampleDuration':
        'type': 'number'
        'flag': 0x08
    'defaultSampleSize':
        'type': 'number'
        'flag': 0x10
    'defaultSampleFlags':
        'type': 'number'
        'flag': 0x20
    'durationIsEmpty':
        'type': 'boolean'
        'flag': 0x10000

module.exports.decode = (buffer, offset) ->
    tools.readBoxProperties buffer, properties

module.exports.encode = (data) ->
    tools.writeBoxProperties data, properties