$(function () {
    if (!$('#area-chart').length) { return false; }
    area();
    $(window).resize (App.debounce (area, 250));
});

function area () {
    $('#area-chart').empty ();

    Morris.Area ({
        element: 'area-chart',
        data: [
            {date: '2013-11-06', blacklisted: 15, suspect: 90, whitelisted: 2},
            {date: '2013-11-07', blacklisted: 5, suspect: 89, whitelisted: 1},
            {date: '2013-11-08', blacklisted: 34, suspect: 196, whitelisted: 0},
            {date: '2013-11-09', blacklisted: 37, suspect: 359, whitelisted: 0},
            {date: '2013-11-10', blacklisted: 68, suspect: 560, whitelisted: 0},
            {date: '2013-11-11', blacklisted: 23, suspect: 201, whitelisted: 1},
            {date: '2013-11-12', blacklisted: 50, suspect: 379, whitelisted: 0}
        ],
        xkey: 'date',
        ykeys: ['blacklisted', 'suspect', 'whitelisted'],
        labels: ['Blacklisted', 'Suspect', 'Whitelisted'],
        pointSize: 5,
        hideHover: 'auto',
        lineColors: [App.chartColors[0], App.chartColors[1], App.chartColors[3]]
    });
}
