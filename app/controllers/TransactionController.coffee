users        = require "../models/users"
drinks       = require "../models/drinks"
transactions = require "../models/transactions"
bluebird     = require "bluebird"
err          = require "error-registry"
schema       = require "../schemas/TransactionSchema"

module.exports =
  schema: schema
  buy: (req, res, next) ->
    users.auth req.body.user
      .then (res) ->
        if not res.success
          next err.get "auth"
        else
          transactions.buy_drink res.username, req.body.drinks
            .then (result) ->
              if result.success
                res.json result
              else
                next result.error
            .catch (err) ->
              next status: 500, error: err.message.toString()

  deposit: (req, res, next) ->
      bluebird.all [
          users.auth req.body.user
          users.auth req.body.authority, "deposit"
      ]
      .then (res) ->
        if (res.every ({success}) -> success)
          transactions.deposit res[0].name, req.body.amount, res[1].name
            .then ->
              res.json {success:true}
        else
          next err.get "auth"

  reverse: (req, res, next) ->
    transactions.reverse req.body.uuid
      .then (ret) ->
        res.json ret

  pull: (req, res, next) ->
    res.json transactions.pull req.body.n

