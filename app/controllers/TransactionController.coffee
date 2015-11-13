users        = require "../models/users"
drinks       = require "../models/drinks"
transactions = require "../models/transactions"
bluebird     = require "bluebird"
schema = require "../schemas/TransactionSchema"

module.exports =
  schema: schema
  buy: (req, res, next) ->
    users.auth_password req.body.user, req.body.password
      .then (success) ->
        if not success
          next status: 401, error:"auth failed"
        else
          transactions.buy_drink req.body.user, req.body.drinks
            .then (result) ->
              res.json result
              next()
            .catch (err) ->
              next status: 400, error:err.message

  deposit: (req, res, next) ->
      bluebird.all [
          users.auth_password req.body.user.name, req.body.user.password
          users.auth_password req.body.authority.name, req.body.authority.password, "deposit"]
      .then (success) ->
        if (success.every (x) -> x)
          transactions.deposit req.body.user.name, req.body.amount, req.body.authority.name
            .then ->
              res.json {success:true}
              next()
        else
          next status: 401, error:"auth failed"

  reverse: (req, res, next) ->
    transactions.reverse req.body.uuid
      .then (ret) ->
        res.json ret
        next()

