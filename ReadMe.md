### [d3panels](http://kbroman.org/d3panels): D3-based graphics panels

[Karl W Broman](http://kbroman.org)

This is a set of [D3](http://d3js.org)-based graphics panels, to
be combined into larger multi-panel charts.  They were developed for
the [R/qtlcharts](http://kbroman.org/qtlcharts) package.

There are other libraries with similar goals that are of more general
use (e.g., [C3.js](http://c3js.org) and
[d3.Chart](http://misoproject.com/d3-chart/); see
[this list of javascript chart libraries](http://blog.webkid.io/javascript-chart-libraries/)),
but I wanted charts that were a bit _less_ general and flexible, but
rather more specific to my particular applications (and style).

For snapshots and live tests, see <http://kbroman.org/d3panels>.

I'm in the process of completely re-writing the library so that it
will be simpler to use, maintain, and extend.

#### Usage

For each chart, you first call the chart function with a set of
options, like this:

```coffeescript
mychart = lodchart({height:600, width:800, ylab="LOD score"})
```

Then you call the function that's created with some selection and the
data:

```coffeescript
mychart(d3.select("div#chart"), mydata)
```


#### License

Licensed under the
[MIT license](License.md). ([More information here](http://en.wikipedia.org/wiki/MIT_License).)
