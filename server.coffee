express        = (require "express")()

express.set "x-powered-by", false

router         = require("./rest-router") express, "./app/controllers"

middlewareconf = require "./config/middleware"
middlewareconf?.before?.call use: express.use.bind express

routeconf      = require "./config/routes"
routeconf.call router

middlewareconf?.after?.call use: express.use.bind express

http      = require "http"
http.createServer(express).listen(8080)
