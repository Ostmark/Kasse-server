redis = require "../../config/redis"
# search = require "./search"

module.exports =
# creates a drink
  make: (name, amount, cost, barcode) ->
    pipeline = redis.hmset "drinks:#{barcode}", {name, amount, cost}
# gets a drink
  get: (barcode) ->
    redis
      .pipeline()
# Check if the drink exists
      .exists "drinks:#{ barcode }"
# Get relevant fields
      .hmget "drinks:#{ barcode }", "name", "amount", "cost"
      .exec()
      .then ( data ) ->
        [[x, exists], [x, [name, amount, cost]]] = data
        if exists
          {barcode, name, amount, cost}
        else
          null
  # not used yet
  search: (string, max) ->
    redis
      .lrange "search:drinks:#{string}", 0, max

  delete: (barcode) ->
    redis
      .del "drinks:#{ barcode }"
      .then (reply) ->
        reply == 1
