users = require "../models/users"
bluebird = require "bluebird"
schema = require "../schemas/RoleSchema"
err = require "error-registry"

module.exports =
  schema: schema
  create: (req, res, next) ->
    users.auth req.body.authority, "roles"
    .then (auth) ->
      if auth.success
        users
          .roles req.params.user
          .set req.params.role
        res
          .json success:true
      else
        next err.get "auth"

  delete: (req, res) ->
    users
      .roles req.params.user
      .delete req.params.role
