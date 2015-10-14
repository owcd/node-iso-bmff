tools = require '../tools'

# element properties
properties =
    'trackId':
        'type': 'number'
    'defaultSampleDescriptionIndex':
        'type': 'number'
    'defaultSampleDuration':
        'type': 'number'
    'defaultSampleSize':
        'type': 'number'
    'defaultSampleFlags':
        'type': 'number'

module.exports.decode = (buffer, offset) ->
    tools.readBoxProperties buffer, properties

module.exports.encode = (data) ->
    tools.writeBoxProperties data, properties