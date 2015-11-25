#!/usr/bin/env coffee

users = require "../app/models/users"

users
  .make "kasse", "Kasse", "admin", "0000000000000"
  .then ->
    users
      .roles "kasse"
      .set "roles"
  .then ->
    process.exit 0


