bodyParser = require 'body-parser'
morgan = require 'morgan'

module.exports =
  before:->
    @use morgan 'dev'
    @use bodyParser.json()
  after: ->
    @use (err, req, res, next) ->
      if err.status?
        res
        .status err.status
        .json {success:false, error:err.error}
      else
        next err
