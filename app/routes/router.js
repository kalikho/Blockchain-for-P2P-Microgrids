var express = require("express");
var router = express.Router();

router.get("/date", function(req, res, next){
        res.send("2021-01-01");
        next();
});

router.get("/time", function(req,res,next){
        res.send(JSON.stringify({ a: 1 }));
});

router.get("/incomingenergy", function(req,res,next){
    res.send("100kW");
});

module.exports = router;
