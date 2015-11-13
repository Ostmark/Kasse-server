redis = require "../../config/redis.coffee"
bcrypt = require "bcrypt"
bluebird = require "bluebird"

UserExistsException = ->
  @prototype = Exception.prototype
  @message = "user already exist"
UserNotExistsException = ->

module.exports =
  make: (name, fullname, password) ->
    redis.exists "name"
      .then (exists) ->
        if exists
          throw new UserExistsException()
        else
          (bluebird.promisify bcrypt.hash) password, 8
      .then (hash) ->
        redis.hmset "users:#{name}",
          fullname: fullname,
          balance:  0
          password: hash
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
  auth_password: (user, password, role) ->
    redis
      .hmget "users:#{user}", "password", role
      .then (result) ->
        [hash, has_role] = result
        if role? and not has_role?
          false
        else if not hash?
          throw new UserNotExistsException()
        else
          (bluebird.promisify bcrypt.compare) password, hash
  roles: (user) ->
    set: (authority, role) ->
      redis
        .hmset "users:#{user.name}", "#{role}":authority
    delete: (role) ->
      redis
        .hdel "users:#{name}", "#{role}"
