app = require "../../fixtures/app"
db = require "../../fixtures/connection"
User = db.model "User"
seedData = require "../../fixtures/seedData"
request = require "request"
should = require "should"

describe "crudify integration", ->

  describe 'PUT /users/:id', ->

    it 'should return error on no write', (done) ->
      User.findOne().exec (err, user) ->
        opt =
          method: "PUT"
          uri: app.url "/users/#{user._id}"
          json:
            name: "Rob"
          headers:
            hasWrite: 'false'
          
        request opt, (err, res, body) ->
          should.not.exist err
          res.statusCode.should.equal 401
          should.exist body
          should.exist body.error
          should.exist body.error.message
          body.error.message.should.equal "Not authorized"
          done()

