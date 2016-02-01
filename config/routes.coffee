module.exports = ->
  @resource 'drink'
  user = @resource 'user'
  user.resource "role"

  @post '/buy', "transaction#buy"
  @post '/deposit', "transaction#deposit"
  @post '/reverse', "transaction#reverse"
  @post '/transaction/pull', "transaction#pull"
  @post '/barcode', "barcode#generate"
