Environment = require '../../../lib/environment'
Method = require '../../../lib/meta/method'

describe 'Method', ->

  it 'parses documentation', ->
    environment = Environment.read('spec/_templates/methods/dynamic_methods.coffee')

    method = Method.fromDocumentationMethod environment.entities[1].documentation.methods[0]
    expect(method).toEqual
      name: 'set'
      type: 'dynamic'
      parameters: ['key', 'value']

    method = Method.fromDocumentationMethod environment.entities[1].documentation.methods[1]
    expect(method).toEqual
      name: 'get'
      type: 'static'
      parameters: ['key']

    method = Method.fromDocumentationMethod environment.entities[1].documentation.methods[2]
    expect(method).toEqual
      name: 'delete'
      type: 'dynamic'
      parameters: ['{key, passion}', "foo = 'bar'"]

  it 'parses entities', ->
    environment = Environment.read('spec/_templates/methods/method_documentation.coffee')

    method = Method.fromMethodEntity environment.entities[2]
    expect(method).toEqual
      name: 'fetchLimit'
      type: 'dynamic'
      parameters: []

    method = Method.fromMethodEntity environment.entities[3]
    expect(method).toEqual
      name: 'do'
      type: 'dynamic'
      parameters: ['it', 'again', 'options']

    method = Method.fromMethodEntity environment.entities[4]
    expect(method).toEqual
      name: 'doWithoutSpace'
      type: 'dynamic'
      parameters: ['it', 'again', 'options']

    method = Method.fromMethodEntity environment.entities[5]
    expect(method).toEqual
      name: 'lets_do_it'
      type: 'static'
      parameters: ['it', 'options']
