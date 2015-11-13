users = require "../models/users"
bluebird = require "bluebird"
schema = require "../schemas/UserSchema"

module.exports =
  schema: schema
  create: (req, res) ->
    users.make req.body.username,
      req.body.full_name,
      req.body.password
    res.json {"success":true}

  show: (req, res, next) ->
    users
      .get req.params.user
      .then (user) ->
        if (user)
          res.json user
          next()
        else
          next {status: 404, error: "user not found"}

