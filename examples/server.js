var SSE = require('express-sse');
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var sse = new SSE();

// routing
app.use(express.static('static'));
app.use(express.static('output'));

app.post("/ping", function(req, res) {
  sse.send({msg: "pong"});
  res.end();
});

app.post("/event/:type", function(req, res) {
  sse.send({msg: "event"}, req.params.type);
  res.end();
});

app.get('/stream', sse.init);

app.listen(8000, function() {
  console.log("Listening on port 8000");
});
