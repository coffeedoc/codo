API = require '../../lib/command.coffee'
Path = require 'path'

describe 'API', ->

  it 'parses project', (done) ->
    api = new API()
    api.generate Path.join(__dirname, '../_templates/example'), { test: true }, (err) ->
      expect(err).toBeUndefined()
      done()

  it 'fails if coverage is too low', (done) ->
    api = new API()
    api.generate Path.join(__dirname, '../_templates/example'), { test: true, "min-coverage": 90 }, (err) ->
      expect(err).toBe 1
      done()

