$(function () {
    
    var d1, d2, data, chartOptions;

    d1 = [
        [1262304000000, 5], [1264982400000, 200], [1267401600000, 1605], [1270080000000, 1129], 
        [1272672000000, 1163], [1275350400000, 1905], [1277942400000, 2002], [1280620800000, 2917], 
        [1283299200000, 2700], [1285891200000, 2700], [1288569600000, 2100], [1291161600000, 1700]
    ];
 
    d2 = [
        [1262304000000, 434], [1264982400000, 232], [1267401600000, 475], [1270080000000, 553],
        [1272672000000, 675], [1275350400000, 679], [1277942400000, 789], [1280620800000, 1026], 
        [1283299200000, 1640], [1285891200000, 1892], [1288569600000, 2147], [1291161600000, 2256]
    ];

    data = [{ 
        label: "Total visitors", 
        data: d1, 
        color: '#e5412d'
    }, {
        label: "Total Sales",
        data: d2,
        color: '#f0ad4e'
    }];
 
    chartOptions = {
        xaxis: {
            min: (new Date(2009, 12, 1)).getTime(),
            max: (new Date(2010, 11, 2)).getTime(),
            mode: "time",
            tickSize: [1, "month"],
            monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
            tickLength: 0
        },
        yaxis: {

        },
        series: {
            lines: {
                show: true, 
                fill: false,
                lineWidth: 2.5
            },
            points: {
                show: true,
                radius: 4.5,
                fill: true,
                fillColor: "#ffffff",
                lineWidth: 2.5
            }
        },
       grid: { 
            hoverable: true, 
            clickable: false, 
            borderWidth: 0 
        },
        legend: {
            show: false
        },
        
        tooltip: true,
        tooltipOpts: {
            content: '%s: %y'
        }
    };

    

    var holder = $('#chart1');

    if (holder.length) {
        $.plot(holder, data, chartOptions );
    }


});