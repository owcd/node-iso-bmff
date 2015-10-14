# require modules
stream = require 'stream'
Buffers = require 'buffers'
tools = require './tools'


module.exports = class Decoder extends stream.Transform

    # constructor
    constructor: (options = {}) ->
        # set object mode
        options.readableObjectMode = true

        # call super
        super options

        # own properties
        @_cursor = 0
        @_length = 0
        @_buffer = null

    # transform the stream
    _transform: (chunk, encoding, done) ->
        if @_buffer?
            @_buffer.push chunk
        else
            @_buffer = new Buffers [chunk]

        while @_buffer? and @_cursor < @_buffer.length
            if not @_readBox()
                break;

        done()

    _readBox: ->
        box = tools.readBox @_cursor, @_buffer, @_length
        if box?
            # push the box
            @push box

            # advance cursor
            if (@_cursor + box.length < @_buffer.length)
                @_buffer = new Buffers([@_buffer.slice(@_cursor + box.length)]);
            else
                @_buffer = null
            @_cursor = 0
            @_length += box.length

            # success
            true
        else
            false
