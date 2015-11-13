t = (require "json.types").types
User = require "./user"

module.exports =
    buy:
      drinks:    [t.String]
      user:       User
      password:   t.String
    deposit:
      user:       User
      authority:  User
      amount:     t.Number
    reverse:
      uuid: t.String

