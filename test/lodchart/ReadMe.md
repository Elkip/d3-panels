### Reusable LOD score chart

A reusable chart for plotting LOD curves
across a genome, following
[Mike Bostock](http://bost.ocks.org/mike)'s
[Towards Reuseable Charts](http://bost.ocks.org/mike/chart/).

For an illustration of its use, see [test_lodchart.coffee](https://github.com/kbroman/qtlcharts/blob/master/inst/panels/lodchart/test/test_lodchart.coffee).

Add see it in action [here](http://kbroman.org/qtlcharts/assets/panels/lodchart/test).

Here are all of the options:

```coffeescript
mychart = lodchart().lodvarname("lod")                                       # variable containing LOD to plot
                    .width(800)                                              # internal width of chart
                    .height(500)                                             # internal height
                    .margin({left:60, top:40, right:40, bottom:40, inner:5}) # margins
                    .axispos({xtitle:25, ytitle:30, xlabel:5, ylabel:5})     # spacing for axis titles and labels
                    .titlepos(20)                                            # spacing for panel title
                    .ylim(null)                                              # y-axis limits
                    .nyticks(5)                                              # no. y-axis ticks
                    .yticks(null)                                            # locations of y-axis ticks
                    .chrGap(8)                                               # gap between chromosomes in pixels
                    .darkrect("#c8c8c8")                                     # even chr rectangle color
                    .lightrect("#e6e6e6")                                    # odd chr rectangle color
                    .linecolor("darkslateblue")                              # color for LOD curves
                    .linewidth(2)                                            # width of LOD curves
                    .pointcolor("#E9CFEC")                                   # color of points a markers
                    .pointsize(0)                                            # radius of points at markers (0=hidden)
                    .title("")                                               # panel title
                    .xlab("Chromosome")                                      # x-axis label
                    .ylab("LOD score")                                       # y-axis label
                    .rotate_ylab(null)                                       # rotate y-axis label
```

#### Organization of data

The data is a hash with a number of components:

- `"chrnames`" is an ordered list of chromosome names
- `"lodnames"` is an ordered list of the names of LOD score columns
- `"chr"` is an ordered list of chromosome IDs for the markers/pseudomarkers
  at which LOD scores were calculated (length `n`)
- `"pos"` is an ordered list of numeric positions for the markers/pseudomarkers
  at which LOD scores were calculated (length `n`)
- additional ordered lists, named as in `"lodnames"`, containing LOD
  scores, each also of length `n`.
- `"markernames"` vector of marker names, of length `n`. Pseudomarkers
  should have an empty string (`""`).

Here's an example dataset: [`data.json`](http://kbroman.org/qtlcharts/assets/panels/lodchart/test/data.json).

#### Additional accessors:

```coffeescript
# x-axis scale
xscale = mychart.xscale()
xscale[chrname](pos)

# y-axis scale
yscale = mychart.yscale()
yscale(lod)

# function for plotting LOD curves, using 'path'
lodcurve = mychart.lodcurve()

# selection of points at markers, to add .on("click", ...)
markerSelect = mychart.markerSelect()
```
