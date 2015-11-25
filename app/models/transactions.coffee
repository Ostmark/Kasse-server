redis = require "../../config/redis"
_ = require "lodash"
uuid = require "uuid"
err = require "error-registry"

module.exports =
  balance_error: Symbol "balance"
# takes a user and a barcode
#
# returns `{success: true}` on success,
# and `{success: false, error: error}` on error
  buy_drink: (user, drinks) ->

    pipeline = redis
      .pipeline()
# Count how many drinks of each type were ordered and transform into pairs of the form
# `[[drink, amount]...]`
    drinks = _.pairs _.countBy(drinks)
# Request the cost for each drink
    _.forOwn drinks, ([drink, amount]) ->
      pipeline.hmget "drinks:#{ drink }", "cost"
    pipeline
# Request the users balance
      .hmget "users:#{ user }", "balance"
      .exec()
        .then ([costs..., [_1, balance]]) ->
# Zip the results to `[[[drink, amount], [success, cost]]...]`
          cost = _.reduce (_.zip drinks, costs),
# Then reduce to cost by summing `cost * amount`
            (acc, [[drink, amount], [_2, cost]]) -> acc + (parseInt cost) * amount,
            0
# Check if the user can afford the order
          if (parseInt balance) <  cost
            {success: false, error: err.get "balance"}
          else
            uuid_ret = uuid.v4()
            transaction =
                JSON.stringify
                  type:   "buy"
                  user:   user
                  drinks: drinks
# called amount for polymorphism
                  amount:   cost
# The uuid is used for reversals
                  uuid: uuid_ret
            redis
              .pipeline()
# Push a transaction into the transaction list
              .lpush "transaction", transaction
# Subtract cost from the users balance
              .hincrby "users:#{ user }", "balance", -cost
# Save transaction for reversals
              .set "uuid:#{ uuid_ret }", transaction
# Transaction can be reversed for an hour
              .expire "uuid:#{ uuid_ret }", 3600
              .exec()
              .then ->
                success: true,
# Return the uuid as a handle
                uuid: uuid_ret

# Deposits `amount` to `user`s account.
# Assumes the authorising party was authorised
  deposit: (user, amount, authorised_by) ->
    redis
      .pipeline()
# Push a transaction
      .lpush "transactions",
        JSON.stringify
          type: "deposit"
          user: user
          authorised_by: authorised_by
          amount: amount
# Increment balance
      .hincrby "users:#{ user }", "balance", amount
      .exec()

# Reverses the transaction `uuid_in`
  reverse: (uuid_in) ->
    redis.pipeline()
# Check if the transaction exists
      .exists "uuid:#{ uuid_in }"
# Get the transaction
      .get "uuid:#{ uuid_in }"
      .exec()
      .then ([[_1, exists], [_2, transaction]]) ->
# If the transaction doesn't exist anymore return error
        if !exists then return {success: false, error: "transaction doesn't exist"}
        JSON.parse transaction
      .then (transaction) ->
        redis.pipeline()
# Delete the transaction
          .delete("uuid:#{ uuid_in }")
# Refund or defund the users account. (we assume a defund needs to happen, so we don't check for negative balance)
          .hincr "user:#{ transaction.user }", -transaction.amount
          .lpush JSON.stringify
            type: "reversal"
            amount: -transaction.amount
            user: transaction.user
# uuid of the original transaction, reversals cannot be reversed
            uuid: uuid_in
          .exec()
        .then () ->
          {success: true}
  pull: (n) ->
    pipeline = redis.pipeline()
    for i in [0..n]
      pipeline.rpop "transactions"
    pipeline.exec().then (res_list) ->
      res_list = res_list
        .filter (res) -> res[1]?
        .map ([_, res]) -> JSON.parse res
      {success: true, n: res_list.length, result: res_list}


