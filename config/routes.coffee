module.exports = ->
  @resource 'drink'
  user = @resource 'user'
  user.resource "role"

  transaction = @load 'transaction'
  @post '/buy', "transaction#buy"
  @post '/deposit', "transaction#deposit"

