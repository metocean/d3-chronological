moment = require 'moment-timezone'
chrono = require 'chronological'
moment = chrono moment

#console.log moment.spanner('/w').format 'YYYY-MM-DD[T]HH:mm:ssZ'

require '../'

margin =
  top: 20
  right: 100
  bottom: 20
  left: 100
width = 960 - margin.left - margin.right
height = 150 - margin.top - margin.bottom

domain = [
  moment.utc('2015-10-18T14:26:16Z')
  moment.utc('2015-10-18T14:26:17Z')
]

x1 = d3.time.scale.utc()
  .domain(domain)
  .nice(d3.time.week.utc)
  .range([0, width])

svg1 = d3
  .select('body')
  .append('svg')
  .attr('width', width + margin.left + margin.right)
  .attr('height', height + margin.top + margin.bottom)
  .append('g')
  .attr('transform', "translate(#{margin.left},#{margin.top})")

svg1.append('g')
  .attr('class', 'x axis')
  .call(d3.svg.axis().scale(x1).orient('bottom'))

x2 = d3.time.scale.chrono('Pacific/Auckland')
  .domain(domain)
  .nice(moment().tz('Pacific/Auckland').startOf('w').every(1, 'w'))
  .range([0, width])

svg2 = d3
  .select('body')
  .append('svg')
  .attr('width', width + margin.left + margin.right)
  .attr('height', height + margin.top + margin.bottom)
  .append('g')
  .attr('transform', "translate(#{margin.left},#{margin.top})")

svg2.append('g')
  .attr('class', 'x axis')
  .call(d3.svg.axis().scale(x2).orient('bottom'))