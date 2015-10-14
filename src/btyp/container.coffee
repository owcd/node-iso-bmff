tools = require '../tools'
Buffers = require 'buffers'

module.exports.decode = (buffer, offset) ->
    tools.readBoxes 0, buffer, offset

module.exports.encode = (data) ->
    buffers = new Buffers()
    for box in data
        buffers.push tools.writeBox box
    buffers.toBuffer()
