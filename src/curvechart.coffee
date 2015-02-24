# curvechart: reuseable chart with many curves

curvechart = () ->
    width = 800
    height = 500
    margin = {left:60, top:40, right:40, bottom: 40, inner:5}
    axispos = {xtitle:25, ytitle:30, xlabel:5, ylabel:5}
    titlepos = 20
    xlim = null
    ylim = null
    nxticks = 5
    xticks = null
    nyticks = 5
    yticks = null
    rectcolor = "#e6e6e6"
    strokecolor = null
    strokecolorhilit = null
    strokewidth = 2
    strokewidthhilit = 2
    title = ""
    xlab = "X"
    ylab = "Y"
    rotate_ylab = null
    yscale = d3.scale.linear()
    xscale = d3.scale.linear()
    curvesSelect = null
    commonX = true

    ## the main function
    chart = (selection) ->
        selection.each (data) ->

            # grab indID if it's there
            # if no indID, create a vector of them
            indID = data?.indID ? null
            indID = indID ? [1..data.data.length]

            # groups of colors
            group = data?.group ? (1 for i of data.data)
            ngroup = d3.max(group)
            group = (g-1 for g in group) # changed from (1,2,3,...) to (0,1,2,...)
            displayError("group values out of range") if sumArray(g < 0 or g > ngroup-1 for g in group) > 0

            # default light stroke colors
            strokecolor = strokecolor ? selectGroupColors(ngroup, "pastel")
            strokecolor = expand2vector(strokecolor, ngroup)

            # default dark stroke colors
            strokecolorhilit = strokecolorhilit ? selectGroupColors(ngroup, "dark")
            strokecolorhilit = expand2vector(strokecolorhilit, ngroup)

            # reorganize data?
            if commonX # reorganize data
                data = ({x:data.x, y:data.data[i]} for i of data.data)
            else
                data = data.data

            # check lengths
            if data.length != group.length
                displayError("data.length (#{data.length}) != group.length (#{group.length})")
            if data.length != indID.length
                displayError("data.length (#{data.length}) != indID.length (#{indID.length})")
            if sumArray(ind_data.x.length != ind_data.y.length for ind_data in data) > 0
                displayError("At least one curve with x.length != y.length")

            xlim = xlim ? matrixExtent(pullVarAsArray(data, "x"))
            ylim = ylim ? matrixExtent(pullVarAsArray(data, "y"))

            # reorganize again
            for i of data
                tmp = data[i]
                data[i] = []
                for j of tmp.x
                    data[i].push({x:tmp.x[j], y:tmp.y[j]}) unless !tmp.x[j]? or !tmp.y[j]?

            # Select the svg element, if it exists.
            svg = d3.select(this).selectAll("svg").data([data])

            # Otherwise, create the skeletal chart.
            gEnter = svg.enter().append("svg").attr("class", "d3panels").append("g")

            # Update the outer dimensions.
            svg.attr("width", width+margin.left+margin.right)
               .attr("height", height+margin.top+margin.bottom)

            g = svg.select("g")

            # box
            g.append("rect")
             .attr("x", margin.left)
             .attr("y", margin.top)
             .attr("height", height)
             .attr("width", width)
             .attr("fill", rectcolor)
             .attr("stroke", "none")

            # scales
            xrange = [margin.left+margin.inner, margin.left+width-margin.inner]
            yrange = [margin.top+height-margin.inner, margin.top+margin.inner]
            xscale.domain(xlim).range(xrange)
            yscale.domain(ylim).range(yrange)
            xs = d3.scale.linear().domain(xlim).range(xrange)
            ys = d3.scale.linear().domain(ylim).range(yrange)

            # if yticks not provided, use nyticks to choose pretty ones
            yticks = yticks ? ys.ticks(nyticks)
            xticks = xticks ? xs.ticks(nxticks)

            # title
            titlegrp = g.append("g").attr("class", "title")
             .append("text")
             .attr("x", margin.left + width/2)
             .attr("y", margin.top - titlepos)
             .text(title)

            # x-axis
            xaxis = g.append("g").attr("class", "x axis")
            xaxis.selectAll("empty")
                 .data(xticks)
                 .enter()
                 .append("line")
                 .attr("x1", (d) -> xscale(d))
                 .attr("x2", (d) -> xscale(d))
                 .attr("y1", margin.top)
                 .attr("y2", margin.top+height)
                 .attr("fill", "none")
                 .attr("stroke", "white")
                 .attr("stroke-width", 1)
                 .style("pointer-events", "none")
            xaxis.selectAll("empty")
                 .data(xticks)
                 .enter()
                 .append("text")
                 .attr("x", (d) -> xscale(d))
                 .attr("y", margin.top+height+axispos.xlabel)
                 .text((d) -> formatAxis(xticks)(d))
            xaxis.append("text").attr("class", "title")
                 .attr("x", margin.left+width/2)
                 .attr("y", margin.top+height+axispos.xtitle)
                 .text(xlab)

            # y-axis
            rotate_ylab = rotate_ylab ? (ylab.length > 1)
            yaxis = g.append("g").attr("class", "y axis")
            yaxis.selectAll("empty")
                 .data(yticks)
                 .enter()
                 .append("line")
                 .attr("y1", (d) -> yscale(d))
                 .attr("y2", (d) -> yscale(d))
                 .attr("x1", margin.left)
                 .attr("x2", margin.left+width)
                 .attr("fill", "none")
                 .attr("stroke", "white")
                 .attr("stroke-width", 1)
                 .style("pointer-events", "none")
            yaxis.selectAll("empty")
                 .data(yticks)
                 .enter()
                 .append("text")
                 .attr("y", (d) -> yscale(d))
                 .attr("x", margin.left-axispos.ylabel)
                 .text((d) -> formatAxis(yticks)(d))
            yaxis.append("text").attr("class", "title")
                 .attr("y", margin.top+height/2)
                 .attr("x", margin.left-axispos.ytitle)
                 .text(ylab)
                 .attr("transform", if rotate_ylab then "rotate(270,#{margin.left-axispos.ytitle},#{margin.top+height/2})" else "")

            indtip = d3.tip()
                       .attr('class', 'd3-tip')
                       .html((d) -> indID[d])
                       .direction('e')
                       .offset([0,10])
            svg.call(indtip)

            curve = d3.svg.line()
                     .x((d) -> xscale(d.x))
                     .y((d) -> yscale(d.y))

            curves = g.append("g").attr("id", "curves")
            curvesSelect =
               curves.selectAll("empty")
                     .data(d3.range(data.length))
                     .enter()
                     .append("path")
                     .datum((d) -> data[d])
                     .attr("d", curve)
                     .attr("class", (d,i) -> "path#{i}")
                     .attr("fill", "none")
                     .attr("stroke", (d,i) -> strokecolor[group[i]])
                     .attr("stroke-width", strokewidth)
                     .on "mouseover.panel", (d,i) ->
                                               d3.select(this).attr("stroke", strokecolorhilit[group[i]]).moveToFront()
                                               circle = d3.select("circle#hiddenpoint#{i}")
                                               indtip.show(i, circle.node())
                     .on "mouseout.panel", (d,i) ->
                                               d3.select(this).attr("stroke", strokecolor[group[i]]).moveToBack()
                                               indtip.hide()

            # grab the last non-null point from each curve
            lastpoint = ({x:null, y:null} for i of data)
            for i of data
                for v in data[i]
                    lastpoint[i] = v if v.x? and v.y?

            pointsg = g.append("g").attr("id", "invisiblepoints")
            points = pointsg.selectAll("empty")
                            .data(lastpoint)
                            .enter()
                            .append("circle")
                            .attr("id", (d,i) -> "hiddenpoint#{i}")
                            .attr("cx", (d) -> xscale(d.x))
                            .attr("cy", (d) -> yscale(d.y))
                            .attr("r", 1)
                            .attr("opacity", 0)

            # box
            g.append("rect")
             .attr("x", margin.left)
             .attr("y", margin.top)
             .attr("height", height)
             .attr("width", width)
             .attr("fill", "none")
             .attr("stroke", "black")
             .attr("stroke-width", "none")

    ## configuration parameters
    chart.width = (value) ->
                      return width if !arguments.length
                      width = value
                      chart

    chart.height = (value) ->
                      return height if !arguments.length
                      height = value
                      chart

    chart.margin = (value) ->
                      return margin if !arguments.length
                      margin = value
                      chart

    chart.axispos = (value) ->
                      return axispos if !arguments.length
                      axispos = value
                      chart

    chart.titlepos = (value) ->
                      return titlepos if !arguments.length
                      titlepos = value
                      chart

    chart.xlim = (value) ->
                      return xlim if !arguments.length
                      xlim = value
                      chart

    chart.nxticks = (value) ->
                      return nxticks if !arguments.length
                      nxticks = value
                      chart

    chart.xticks = (value) ->
                      return xticks if !arguments.length
                      xticks = value
                      chart

    chart.ylim = (value) ->
                      return ylim if !arguments.length
                      ylim = value
                      chart

    chart.nyticks = (value) ->
                      return nyticks if !arguments.length
                      nyticks = value
                      chart

    chart.yticks = (value) ->
                      return yticks if !arguments.length
                      yticks = value
                      chart

    chart.rectcolor = (value) ->
                      return rectcolor if !arguments.length
                      rectcolor = value
                      chart

    chart.strokecolor = (value) ->
                      return strokecolor if !arguments.length
                      strokecolor = value
                      chart

    chart.strokecolorhilit = (value) ->
                      return strokecolorhilit if !arguments.length
                      strokecolorhilit = value
                      chart

    chart.strokewidth = (value) ->
                      return strokewidth if !arguments.length
                      strokewidth = value
                      chart

    chart.strokewidthhilit = (value) ->
                      return strokewidthhilit if !arguments.length
                      strokewidthhilit = value
                      chart

    chart.commonX = (value) ->
                      return commonX if !arguments.length
                      commonX = value
                      chart

    chart.title = (value) ->
                      return title if !arguments.length
                      title = value
                      chart

    chart.xlab = (value) ->
                      return xlab if !arguments.length
                      xlab = value
                      chart

    chart.ylab = (value) ->
                      return ylab if !arguments.length
                      ylab = value
                      chart

    chart.rotate_ylab = (value) ->
                      return rotate_ylab if !arguments.length
                      rotate_ylab = value
                      chart

    chart.yscale = () ->
                      return yscale

    chart.xscale = () ->
                      return xscale

    chart.curvesSelect = () ->
                      return curvesSelect

    # return the chart function
    chart
