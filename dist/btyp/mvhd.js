// Generated by CoffeeScript 1.12.2
(function() {
  var BufferIterator, tools;

  tools = require('../tools');

  BufferIterator = require('../bufferIterator');

  module.exports.decode = function(buffer, offset) {
    var data, i, iterator, j, readData;
    iterator = new BufferIterator(buffer);
    data = tools.initBoxData(iterator);
    readData = function() {
      if (data.version === 1) {
        return iterator.read64();
      } else {
        return iterator.read32();
      }
    };
    data.creationTime = readData();
    data.modificationTime = readData();
    data.timeScale = iterator.read32();
    data.duration = readData();
    data.rate = iterator.readFixedPoint1616();
    data.volume = iterator.readFixedPoint88();
    iterator.skip(10);
    data.matrix = [];
    for (i = j = 0; j <= 8; i = ++j) {
      data.matrix.push(iterator.read32());
    }
    iterator.skip(24);
    data.nextTrackId = iterator.read32();
    return data;
  };

  module.exports.encode = function(data) {
    var i, iterator, j, length, writeData;
    length = 96;
    if (data.version === 1) {
      length += 12;
    }
    iterator = tools.writeBoxData(data, length);
    writeData = function(value) {
      if (data.version === 1) {
        return iterator.write64(value);
      } else {
        return iterator.write32(value);
      }
    };
    writeData(data.creationTime);
    writeData(data.modificationTime);
    iterator.write32(data.timeScale);
    writeData(data.duration);
    iterator.writeFixedPoint1616(data.rate);
    iterator.writeFixedPoint88(data.volume);
    iterator.skip(10);
    for (i = j = 0; j <= 8; i = ++j) {
      iterator.write32(data.matrix[i]);
    }
    iterator.skip(24);
    iterator.write32(data.nextTrackId);
    return iterator.buffer;
  };

}).call(this);
