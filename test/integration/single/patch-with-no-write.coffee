app = require "../../fixtures/app"
db = require "../../fixtures/connection"
User = db.model "User"
seedData = require "../../fixtures/seedData"
request = require "request"
should = require "should"

describe "crudify integration", ->

  beforeEach (done) -> app.start -> seedData.create done
  afterEach (done) -> app.close -> seedData.clear done

  describe 'PATCH /users/:id', ->

    it 'should return error on no write', (done) ->
      user = seedData.embed "User"
      opt =
        method: "PATCH"
        uri: app.url "/users/#{user._id}"
        json:
          score: 9001
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
