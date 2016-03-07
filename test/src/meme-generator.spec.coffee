Helper = require 'hubot-test-helper'
request = require 'request'

sinon = require 'sinon'
chai = require 'chai'
assert = chai.assert
expect = chai.expect

helper = new Helper '../../src/meme-generator.coffee'

describe 'ping', ->
  room = undefined

  beforeEach -> room = helper.createRoom()
  afterEach -> room.destroy()
  context 'user tries to create a meme', ->
    getSpy = undefined

    beforeEach ->
      getSpy = sinon.spy request, 'get'
      room.user.say 'alice', 'hubot memegen some text SUCCESS'
    afterEach -> sinon.restore()
    it 'should reply pong to user', (cb) ->
      assert getSpy.called

      setTimeout () ->
        expect(room.messages[ 0 ]).to.eql [
          'alice', 'hubot memegen some text SUCCESS'
        ]
        expect(room.messages[ 1 ][ 0 ]).to.eql 'hubot'
        expect(room.messages[ 1 ][ 1 ]).to.have.string 'http://i.imgflip.com/'
        expect(room.messages[ 1 ][ 1 ]).to.have.string '.jpg'
        cb()
      , 1000