redis = require "../../config/redis.coffee"
bcrypt = require "bcrypt"
bluebird = require "bluebird"
err = require "error-registry"

auth_barcode = (barcode) ->
  redis
    .pipeline()
# check if the barcode exists
    .exists "userbarcode:#{user.barcode}"
# get the name for the barcode
    .get "userbarcode:#{user.barcode}"
    .exec()
    .then ([[_1, exists], [_2, username]]) ->
# if the barcode exists, check if role is set for user
      if exists
        redis
          .hmget "users:#{username}", role ? "invalid_role"
          .then () ->
# return success
            success: true
            role: role?
            username: username
# return failure
      else
        success: false

auth_password = (user, password) ->
  redis
# get the password hash, and try to get the role
    .hmget "users:#{user}", ["password", role ? "invalid_role"]
    .then ([hash, has_role]) ->
      if (bluebird.promisify bcrypt.compare) password, result[0]
        success: true
        role: has_role == "true"
        username: user



module.exports =
  make: (name, fullname, password, barcode) ->
    redis.exists "users:#{name}"
      .then (exists) ->
        if exists
            {sucess: false, error: err.get "exists"}
        else
          (bluebird.promisify bcrypt.hash) password, 8
      .then (hash) ->
        redis
          .pipeline()
          .hmset "users:#{name}",
            fullname: fullname
            balance:  0
            password: hash
          .set "userbarcode:#{barcode}", name
          .exec()
          .then (res) ->
            {success: true}
  get: (name) ->
    redis
      .pipeline()
      .exists "users:#{ name }"
      .hmget "users:#{ name }", ["fullname", "balance"]
      .exec()
      .then (data) ->
        [[err, exists], [err, [fullname, balance]]] = data
        if !exists
          null
        else
          {name, fullname, balance}
  delete: (name) ->
    redis
      .del "users:#{ name }"
      .then (reply) ->
        reply == 1

# Authorizes `user`. Optionally checks if user has role.
  auth: (user, role) ->
    promise = if user.barcode?
      auth_barcode barcode
    else
      auth_password user.name, user.password
    promise .then ({success, has_role, username}) ->
      if role? and not has_role
        success: false
      else
        {success, username}

  roles: (user) ->
    set: (role) ->
      redis
        .hset "users:#{user}", "#{role}", "true"
        .then ->
          {success: true}
    delete: (role) ->
      redis
        .hdel "users:#{name}", "#{role}"
        .then ->
          {success: true}
