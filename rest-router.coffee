# returns a rest-router for the `router` object
# ```
#   app = require 'express'
#   router = require('rest-router')(app, "app/controllers")
# ```

json_types = require 'json.types'
debug      = (require  'debug') 'nails:router'


module.exports = (router, directory) ->
  Resource = (path) ->
    @path = path
  Resource::resource = (name) ->
    resource name, @path

  load = (name) ->
    controllerName = name
      .charAt(0)
      .toUpperCase()
      .concat name.slice(1, name.length)
      .concat "Controller"
    qcontrollerName = "#{directory}/#{ controllerName }"
    require qcontrollerName

  check_schema = (schema) ->
    debug schema
    (req, res, next) ->
      unless json_types.check_schema schema, req.body
        debug req.body
        debug schema
        next {error:"invalid request", status:400}
      else
        next()

  # creates routes for controller `name`
  resource = (name, mountpath) ->
    init_route = (name, route, method) ->
      if controller.schemas?[name]?
        debug "Adding schema checker for #{method.toUpperCase()} #{route.path}"
        route[method] check_schema controller.schemas[name]
      if controller[name]?
        debug "controller added for #{method.toUpperCase()} #{route.path}"
        route[method] controller[name]

    controller = load name

    if !mountpath?
      mountpath = ""
    if mountpath?[0] != "/"
      mountpath = "/#{mountpath}"

    index_route    = router.route "#{mountpath}#{ name }/"
    new_route      = router.route "#{mountpath}#{ name }/new/"
    resource_route = router.route "#{mountpath}#{ name }/:#{ name }/"
    edit_route     = router.route "#{mountpath}#{ name }/:#{ name }/edit/"

    debug "creating resource #{index_route.path}"

    init_route "index", index_route, "get"
    init_route "create", resource_route, "post"
    init_route "new", new_route, "get"
    init_route "show", resource_route, "get"
    init_route "edit", edit_route, "get"
    init_route "update", resource_route, "put"
    init_route "destroy", resource_route, "delete"
    new Resource resource_route.path

  method = (method) ->
    (route, handler) ->
      if typeof handler == "string"
        ## "controller#method"
        result = /(\w+)#(\w+)/.exec handler
        if result?
          controller = load result[1]
          ctl_method = result[2]
          debug "loading special route #{result[1]}##{result[2]}"
          if controller.schemas?[ctl_method]?
            debug "Adding schema checker for #{method.toUpperCase()} #{route}"
            router[method] route, check_schema controller.schemas[ctl_method]
          debug "controller added for #{method.toUpperCase()} #{route}"
          router[method] route, controller[ctl_method]


      else
        router[method] handler

  load: load
  get:    router.get.bind router
  put:    router.put.bind router
  post:  method "post"
  delete: router.delete.bind router
  all:    router.all.bind router
  resource: resource
