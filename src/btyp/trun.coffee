tools = require '../tools'

# element properties
properties =
    'sampleCount':
        'type': 'number'
    'dataOffset':
        'type': 'number'
        'flag': 0x01
    'firstSampleFlags':
        'type': 'number'
        'flag': 0x04
    'entries':
        'ref': 'sampleCount'
        'type':
            'sampleDuration':
                'type': 'number'
                'flag': 0x100
            'sampleSize':
                'type': 'number'
                'flag': 0x200
            'sampleFlags':
                'type': 'number'
                'flag': 0x400
            'sampleCompositionTimeOffset':
                'type': 'number'
                'flag': 0x800

module.exports.decode = (buffer, offset) ->
    tools.readBoxProperties buffer, properties

module.exports.encode = (data) ->
    tools.writeBoxProperties data, properties
