users = require "../models/users"
bluebird = require "bluebird"
schema = require "../schemas/UserSchema"
err = require "error-registry"

module.exports =
  schema: schema
  create: (req, res) ->
    users.make req.body.username,
      req.body.full_name,
      req.body.password
      req.body.barcode
    .then () ->
      res.json success:true

  show: (req, res, next) ->
    users
      .get req.params.user
      .then (user) ->
        if (user)
          res.json user
        else
          next err.get "notfound"

