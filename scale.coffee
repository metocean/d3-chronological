moment = require 'moment-timezone'
chrono = require 'chronological'
moment = chrono moment

ms = (d) ->
  if moment.isMoment d
    d.valueOf()
  else if moment.isDate d
    d.getTime()
  else
    d

domainextent = (domain) -> [domain[0], domain[domain.length - 1]]

units = ['y', 'M', 'w', 'd', 'h', 'm', 's']
selectunit = (domain, count) ->
  for unit in units
    diff = domain[1].diff domain[0], unit
    return unit if diff >= count / 2
  'ms'

powround = (num) ->
  return 1 if num < 1
  Math.pow(10, Math.round(Math.log(num) / Math.LN10))

niceunitnumbers =
  s: [1, 5, 15, 30, 60]
  m: [1, 5, 15, 30, 60]
  h: [1, 3, 6, 12, 24]
  d: [1, 2, 3, 5, 10]
  w: [1, 2, 3, 4, 5, 6]
  M: [1, 3, 6, 12]
  y: [1, 5, 10, 25, 50, 100, 250, 500, 1000]

selectnice = (n, unit) ->
  return powround n if unit is 'ms'
  numbers = niceunitnumbers[unit]
  for num in numbers
    return num if n < num + num * 2
  return numbers[numbers.length - 1]

formats =
  ms: (d) -> "#{d.valueOf()}ms"
  s: (d) -> d.format 'HH:mm:ss'
  m: (d) -> d.format 'h:mma'
  h: (d) -> d.format 'D MMM ha'
  d: (d) -> d.format 'D MMM'
  w: (d) -> d.format 'D MMM'
  M: (d) -> d.format 'D MMM'
  y: (d) -> d.format 'D MMM'

chrono_scale = (linear, tz) ->
  tz ?= 'UTC'

  scale = (x) -> linear ms x
  scale.invert = (x) -> linear.invert x

  scale.domain = (x) ->
    if !arguments.length
      return linear.domain().map (t) -> moment(t).tz(tz)
    linear.domain x.map ms
    scale

  scale.nice = (every) ->
    extent = domainextent linear.domain()
    linear.domain [
      every.before moment extent[0]
      every.after moment extent[1]
    ]
    scale

  scale.ticks = (count) ->
    domain = scale.domain()
    unit = selectunit domain, count
    anchor = moment().tz(tz).startOf('s').startOf unit
    diff = domain[1].diff domain[0], unit
    diff /= count
    diff = selectnice diff, unit
    console.log "#{diff}#{unit}"
    every = anchor.every diff, unit
    startindex = Math.ceil every.count domain[0]
    endindex = Math.floor every.count domain[1]
    return [] if startindex > endindex
    [startindex..endindex].map every.nth

  scale.tickFormat = (count) ->
    domain = scale.domain()
    unit = selectunit domain, count
    formats[unit]
  scale.copy = -> chrono_scale linear.copy(), tz
  d3.rebind scale, linear, 'range', 'rangeRound', 'interpolate', 'clamp'

d3.chrono = {} if !d3.chrono?
d3.chrono.scale = (tz) -> chrono_scale d3.scale.linear(), tz
