(function() {
  var scale;

  scale = require('./scale');

  module.exports = function(d3) {
    return scale(d3);
  };

}).call(this);
