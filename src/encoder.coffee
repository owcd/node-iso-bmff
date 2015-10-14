# require modules
stream = require 'stream'
Buffers = require 'buffers'
tools = require './tools'

module.exports = class Encoder extends stream.Transform

    # constructor
    constructor: (options = {}) ->
        # set object mode
        options.writableObjectMode = true

        # call super
        super options

    # transform the stream
    _transform: (chunk, encoding, done) ->
        @push tools.writeBox chunk
        done()
