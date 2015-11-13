drinks = require "../models/drinks.coffee"
t = (require "json.types").types

module.exports =
  schemas:
    create:
      name: t.String
      size: t.String
      cost: t.Number

  show: (req, res, next) ->
    drinks.get req.params.drink
      .then (result) ->
        if result
          res.json result
          next()
        else
          next status: 404, error:"drink doesn't exist"
      .catch ->
          next status: 405, error:"invalid"

  create: (req, res) ->
    drinks.make req.body.name,
      req.body.size,
      req.body.cost,
      req.params.drink
    .then ->
      res.json {success:true}


