extendQueryFromParams = require '../extendQueryFromParams'
sendError = require '../sendError'
sendResult = require '../sendResult'
authorizeRead = require '../authorizeRead'
defaultPerms = require '../defaultPerms'
execQuery = require '../execQuery'
filterDocument = require '../filterDocument'

module.exports = (route) ->
  [Model] = route.meta.models
  out = {}
    
  out.get = (model, req, res, next) ->
    authorizeRead {collection:Model,args:[req]}, (canReadCollection) =>
      return sendError res, "Not authorized", 401 unless canReadCollection
      query = Model.find()
      query = extendQueryFromParams query, req.query, route.meta

      execQuery.bind(@) model, req, res, query, (err, data) =>
        return sendError res, err if err?
        return sendError res, "Not found", 404 unless data?

        authorizeRead {models:data,args:[req]}, (_, nData) =>
          return sendResult.bind(@) model, req, res, nData

  out.post = (model, req, res, next) ->
    return sendError res, new Error("Invalid body") unless typeof req.body is 'object'
    perms = (if Model.authorize then Model.authorize(req) else defaultPerms)
    return sendError res, "Not authorized", 401 unless perms.read is true
    return sendError res, "Not authorized", 401 unless perms.write is true
    
    delete req.body._id
    delete req.body.__v

    Model.create req.body, (err, data) =>
      return sendError res, err if err?
      nData = filterDocument req, data
      sendResult.bind(@) model, req, res, nData, 201
      return

  return out