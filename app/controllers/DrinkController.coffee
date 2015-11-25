drinks = require "../models/drinks"
t = (require "json.types").types
schema = require "../schemas/DrinkSchema"
err = require "error-registry"
_ = require "lodash"

module.exports =

  show: (req, res, next) ->
    drinks.get req.params.drink
      .then (result) ->
        if result
          res.json _.extend result, success: true
        else
            next err.get "notfound"

  create: (req, res) ->
    drinks.make req.body.name,
      req.body.size,
      req.body.cost,
      req.params.drink
    .then ->
      res.json {success:true}


