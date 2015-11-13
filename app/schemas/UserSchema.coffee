t = (require "json.types").types
User = require "./user"

module.exports =
    create:
      username: t.String
      full_name: t.String
      password: t.String
      barcode:  t.String
    roles:
      create:
        user: User
        authority: User
        role: t.String
      delete:
        user: User
        role: t.String
        authority: User
