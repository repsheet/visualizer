$(document).ready(function() {
    $("#suspects").tablesorter({sortList: [[2,1]],widgets: ['zebra']});
    $("#blacklisted").tablesorter({sortList: [[2,1]],widgets: ['zebra']});
});

function angle(d) {
  var a = (d.startAngle + d.endAngle) * 90 / Math.PI - 90;
  return a > 90 ? a - 180 : a;
}

function pie(dataSet) {
  var canvasWidth = 700,
  canvasHeight = 700,
  outerRadius = 250,
  color = d3.scale.category20();

  var vis = d3.select("#total").append("svg:svg")
                               .data([dataSet]).attr("width", canvasWidth)
                               .attr("height", canvasHeight)
                               .append("svg:g")
                               .attr("transform", "translate(" + 1.5*outerRadius + "," + 1.5*outerRadius + ")")

  var arc = d3.svg.arc().outerRadius(outerRadius);
  var pie = d3.layout.pie().value(function(d) { return d.magnitude; }).sort( function(d) { return null; } );
  var arcs = vis.selectAll("g.slice").data(pie).enter().append("svg:g").attr("class", "slice");

  arcs.append("svg:path").attr("fill", function(d, i) { return color(i); } ).attr("d", arc);

  arcs.append("svg:text").attr("transform", function(d) {
    d.outerRadius = outerRadius + 50;
    d.innerRadius = outerRadius + 45;
    return "translate(" + arc.centroid(d) + ")";
  }).attr("text-anchor", "middle").style("fill", "Purple").style("font", "bold 12px Arial").text(function(d, i) { return dataSet[i].legendLabel; });

  arcs.filter(function(d) { return d.endAngle - d.startAngle > .2; })
    .append("svg:text").attr("dy", ".35em").attr("text-anchor", "middle")
    .attr("transform", function(d) {
      d.outerRadius = outerRadius;
      d.innerRadius = outerRadius/2;
      return "translate(" + arc.centroid(d) + ")";
    }).style("fill", "White").style("font", "bold 12px Arial").text(function(d) { return d.data.magnitude; });
}

function donut(labels, data) {
  var w = 250,
      h = 250,
      r = Math.min(w, h) / 2,
      color = d3.scale.category20(),
      donut = d3.layout.pie().sort(null),
      arc = d3.svg.arc().innerRadius(r - 70).outerRadius(r - 20);

  var svg = d3.select("#individual").append("svg:svg").attr("width", w).attr("height", h);

  var arc_grp = svg.append("svg:g").attr("class", "arcGrp")
                                   .attr("transform", "translate(" + (w / 2) + "," + (h / 2) + ")");

  var label_group = svg.append("svg:g").attr("class", "lblGroup")
                                       .attr("transform", "translate(" + (w / 2) + "," + (h / 2) + ")");

  var center_group = svg.append("svg:g").attr("class", "ctrGroup")
                                        .attr("transform", "translate(" + (w / 2) + "," + (h / 2) + ")");

  var pieLabel = center_group.append("svg:text").attr("dy", ".35em").attr("class", "chartLabel")
                                                .attr("text-anchor", "middle")
                                                .text(data.label);

  var arcs = arc_grp.selectAll("path").data(donut(data.pct));

  arcs.enter().append("svg:path").attr("stroke", "white")
                                 .attr("stroke-width", 0.5)
                                 .attr("fill", function(d, i) {return color(i);})
                                 .attr("d", arc)
                                 .each(function(d) {this._current = d});

  var sliceLabel = label_group.selectAll("text").data(donut(data.pct));

  sliceLabel.enter().append("svg:text").attr("class", "arcLabel")
                                       .attr("transform", function(d) {
                                         return "translate(" + arc.centroid(d) + ")rotate(" + angle(d) + ")";
                                        })
                                       .attr("text-anchor", "middle")
                                       .text(function(d, i) { return labels[i]; });
}
