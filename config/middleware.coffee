bodyParser = require 'body-parser'
morgan = require 'morgan'
debug = (require 'debug') 'kasse:middleware'

module.exports =
  before:->
    @use morgan 'dev'
    @use bodyParser.json()
  after: ->
    debug 'adding error handling'
    @use (err, req, res, next) ->
      if err.status?
        res
          .status err.status
          .json {success:false, error: err.toString()}
      else
        next err
    @use (err, req, res, next) ->
      res
        .status 500
        .json {error: err}
    @use (req, res) ->
        res
          .status 404
          .json {success: false, error: "route doesn't exists"}
