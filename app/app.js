//app.js

var express = require("express");

var app = express();

var logger_morgan = require("morgan");


var express = require("express");
var apiRouter = require("./routes/router");

var app = express();

app.use("/api", apiRouter);
app.listen(3000, function(){
    console.log("Application started and Listening on port 3000");
});
app.use(logger_morgan("short"));
