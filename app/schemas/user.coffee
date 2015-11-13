types: t = (require "json.types").types

module.exports =
  t.Either [
      {
          name: t.String
          password:t.String
      }
      barcode: t.String
  ]


