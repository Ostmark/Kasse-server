_ = require "lodash"
redis = require "../../config/redis"

generate_namespace = () ->
  id = _.random(9999)
  redis
    .pipeline()
    .sismember "namespaces:full", id
    .sismember "namespaces:empty", id
    .exec()
    .then ([[_1, full], [_2, empty]]) ->
      if full or empty
        generate_namespace()
      else
        redis
          .pipeline()
          .sadd "namespaces:full", id
          .sadd "namespace:#{id}", [0...1000]
          .exec()

barcode = (namespace, id) -> "28#{namespace}1930#{id}"

generate_barcode = () ->
  redis.pipeline()
    .srandmember "namespaces:full"
    .scard "namespaces:full"
    .exec()
    .then ([[_1, namespace], [_2, empty]]) ->
      pipeline = redis.pipeline()
      pipeline.spop "namespace:#{namespace}"
      if empty == 0
        pipeline
          .srem "namespaces:full", "namespace:#{namespace}"
          .sadd "namespaces:empty", "namespace:#{namespace}"
        generate_namespace()
      pipeline.exec().then ([[_1, id]]) ->
        barcode namespace, id

module.exports =
   make: generate_barcode
   generate_namespace: generate_namespace
