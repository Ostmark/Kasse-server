generator = require "../models/barcode"

module.exports =
  generate: (req, res, next) ->
    generator.make().then (barcode) ->
      res.json
        success: true
        barcode: barcode
    .catch (error) ->
      console.log error
      next {error: error.message, status: 501}
