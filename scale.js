(function() {
  var chrono, moment;

  moment = require('moment-timezone');

  chrono = require('chronological');

  moment = chrono(moment);

  module.exports = function(d3) {
    var chrono_scale, domainextent, formats, ms, niceunitnumbers, powround, selectnice, selectunit, units;
    ms = function(d) {
      if (moment.isMoment(d)) {
        return d.valueOf();
      } else if (moment.isDate(d)) {
        return d.getTime();
      } else {
        return d;
      }
    };
    domainextent = function(domain) {
      return [domain[0], domain[domain.length - 1]];
    };
    units = ['y', 'M', 'w', 'd', 'h', 'm', 's'];
    selectunit = function(domain, count) {
      var diff, unit, _i, _len;
      for (_i = 0, _len = units.length; _i < _len; _i++) {
        unit = units[_i];
        diff = domain[1].diff(domain[0], unit);
        if (diff >= count / 2) {
          return unit;
        }
      }
      return 'ms';
    };
    powround = function(num) {
      if (num < 1) {
        return 1;
      }
      return Math.pow(10, Math.round(Math.log(num) / Math.LN10));
    };
    niceunitnumbers = {
      s: [1, 5, 15, 30, 60],
      m: [1, 5, 15, 30, 60],
      h: [1, 3, 6, 12, 24],
      d: [1, 2, 3, 5, 10],
      w: [1, 2, 3, 4, 5, 6],
      M: [1, 3, 6, 12],
      y: [1, 5, 10, 25, 50, 100, 250, 500, 1000]
    };
    selectnice = function(n, unit) {
      var num, numbers, _i, _len;
      if (unit === 'ms') {
        return powround(n);
      }
      numbers = niceunitnumbers[unit];
      for (_i = 0, _len = numbers.length; _i < _len; _i++) {
        num = numbers[_i];
        if (n < num + num * 2) {
          return num;
        }
      }
      return numbers[numbers.length - 1];
    };
    formats = {
      ms: function(d) {
        return "" + (d.valueOf()) + "ms";
      },
      s: function(d) {
        return d.format('HH:mm:ss');
      },
      m: function(d) {
        return d.format('h:mma');
      },
      h: function(d) {
        return d.format('D MMM ha');
      },
      d: function(d) {
        return d.format('D MMM');
      },
      w: function(d) {
        return d.format('D MMM');
      },
      M: function(d) {
        return d.format('D MMM');
      },
      y: function(d) {
        return d.format('D MMM');
      }
    };
    chrono_scale = function(linear, tz) {
      var scale;
      if (tz == null) {
        tz = 'UTC';
      }
      scale = function(x) {
        return linear(ms(x));
      };
      scale.invert = function(x) {
        return linear.invert(x);
      };
      scale.domain = function(x) {
        if (!arguments.length) {
          return linear.domain().map(function(t) {
            return moment(t).tz(tz);
          });
        }
        linear.domain(x.map(ms));
        return scale;
      };
      scale.nice = function(every) {
        var extent;
        extent = domainextent(linear.domain());
        linear.domain([every.before(moment(extent[0])), every.after(moment(extent[1]))]);
        return scale;
      };
      scale.ticks = function(count) {
        var anchor, diff, domain, endindex, every, startindex, unit, _i, _results;
        domain = scale.domain();
        unit = selectunit(domain, count);
        anchor = moment().tz(tz).startOf('s').startOf(unit);
        diff = domain[1].diff(domain[0], unit);
        diff /= count;
        diff = selectnice(diff, unit);
        every = anchor.every(diff, unit);
        startindex = Math.ceil(every.count(domain[0]));
        endindex = Math.floor(every.count(domain[1]));
        if (startindex > endindex) {
          return [];
        }
        return (function() {
          _results = [];
          for (var _i = startindex; startindex <= endindex ? _i <= endindex : _i >= endindex; startindex <= endindex ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this).map(every.nth);
      };
      scale.tickFormat = function(count) {
        var domain, unit;
        domain = scale.domain();
        unit = selectunit(domain, count);
        return formats[unit];
      };
      scale.copy = function() {
        return chrono_scale(linear.copy(), tz);
      };
      return d3.rebind(scale, linear, 'range', 'rangeRound', 'interpolate', 'clamp');
    };
    if (d3.chrono == null) {
      d3.chrono = {};
    }
    d3.chrono.scale = function(tz) {
      return chrono_scale(d3.scale.linear(), tz);
    };
    return d3;
  };

}).call(this);
