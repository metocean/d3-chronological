# d3-chronological
d3 components using proper timezone information. Currently only scale has been implemented.

# Scale
Replace `d3.time.scale` with `d3.chrono.scale`.


```js
var x = d3.chrono.scale('Pacific/Auckland')
  .domain([
    moment('2015-01-01'),
    moment('2015-01-02')
  ])
  .nice(moment().tz('Pacific/Auckland').startOf('w').every(1, 'w'))
  .range([0, width]);
```

Create the scale with a timezone identifier from [momentjs timezone](http://momentjs.com/timezone/) or leave blank to use UTC. This timezone is used to create default ticks that align to the correct start of day, etc.

Pass a [chronological](https://github.com/metocean/chronological) time schedule to the nice function to round to the nearest schedule. The above example rounds to the nearest week.

Values are kept as milliseconds past epoch internally and converted to timezone moments on output from `domain()` and `ticks()`. Calculating your own tick values and tick format is suggested - using [chronological](https://github.com/metocean/chronological) makes this easy.