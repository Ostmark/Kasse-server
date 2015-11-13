users = require "../models/users"
bluebird = require "bluebird"
t = (require "json.types").types

module.exports =
  schemas:
    create:
      authority:
        name: t.String
        password: t.String
      role: t.String
  create: (req, res) ->
    users.auth_password req.body.authority.name, req.body.authority.password
    .then (auth) ->
      if auth
        users
          .roles name: req.params.user
          .set req.body.role
        res
          .json success:true
      else
        res.json success:false

  delete: (req, res) ->
