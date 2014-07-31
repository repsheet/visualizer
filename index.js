var redis = require('redis').createClient();
var express = require('express');
var app = express();

app.get('/blacklist', function(req, res) {
  redis.keys("*:*:blacklist", function(err, data) {
    if (data) {
      res.send(data);
    }
  });
});

var server = app.listen(3000, function() {
  console.log("Listening on port %d", server.address().port);
});

