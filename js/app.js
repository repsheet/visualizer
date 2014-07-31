function drawMap() {
  var locations = [
    ["1.1.1.1", "44.968046", "-94.420307"],
    ["1.1.1.2", "44.33328",  "-89.132008"],
    ["1.1.1.3", "33.755787", "-116.359998"]
  ]

  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 2,
    center: new google.maps.LatLng(41.833, -87.731),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });

  var infowindow = new google.maps.InfoWindow();
  var marker, i;

  for (i = 0; i < locations.length; i++) {
    marker = new google.maps.Marker({
      position: new google.maps.LatLng(locations[i][1], locations[i][2]),
      map: map
    });

    google.maps.event.addListener(marker, 'click', (function(marker, i) {
      return function() {
        infowindow.setContent(locations[i][0]);
        infowindow.open(map, marker);
      }
    })(marker, i));
  }
}


App = Ember.Application.create();

App.WorldView = Ember.View.extend({
  didInsertElement: function() {
    drawMap();
  }
});


App.Router.map(function() {
  this.resource("blacklist");
  this.resource("suspects");
  this.resource("whitelist");
  this.resource("world");
});

App.IndexRoute = Ember.Route.extend({
  model: function() {
    return report;
  }
});

App.BlacklistRoute = Ember.Route.extend({
  model: function() {
    return blacklist;
  }
});

App.SuspectsRoute = Ember.Route.extend({
  model: function() {
    return suspects;
  }
});

App.WhitelistRoute = Ember.Route.extend({
  model: function() {
    return whitelist;
  }
});

var actors = [
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "offenses": 1, "requests": 5}
]

var blacklist = [
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5}
]

var suspects = [
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5},
  {"ip":"1.1.1.1", "triggered": [950001], "offenses": 1, "requests": 5}
]

var whitelist = [
  {"ip":"1.1.1.1"},
  {"ip":"1.1.1.1"},
  {"ip":"1.1.1.1"},
  {"ip":"1.1.1.1"},
  {"ip":"1.1.1.1"},
  {"ip":"1.1.1.1"},
  {"ip":"1.1.1.1"},
  {"ip":"1.1.1.1"},
  {"ip":"1.1.1.1"},
  {"ip":"1.1.1.1"}
]

var report = {
  suspects: suspects,
  blacklist: blacklist,
  whitelist: whitelist
}
