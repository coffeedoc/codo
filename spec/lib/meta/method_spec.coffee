Environment = require '../../../lib/environment'
Method = require '../../../lib/meta/method'

describe 'Method', ->

  it 'parses documentation', ->
    environment = Environment.read('spec/_templates/methods/dynamic_methods.coffee')

    method = Method.fromDocumentationMethod environment.entities[1].documentation.methods[0]
    expect(method.inspect()).toEqual
      name: 'set'
      kind: 'dynamic'
      parameters: ['key', 'value']

    method = Method.fromDocumentationMethod environment.entities[1].documentation.methods[1]
    expect(method.inspect()).toEqual
      name: 'get'
      kind: 'static'
      parameters: ['key']

    method = Method.fromDocumentationMethod environment.entities[1].documentation.methods[2]
    expect(method.inspect()).toEqual
      name: 'delete'
      kind: 'dynamic'
      parameters: ['{key, passion}', "foo = 'bar'"]

  it 'parses entities', ->
    environment = Environment.read('spec/_templates/methods/method_documentation.coffee')

    method = Method.fromMethodEntity environment.entities[2]
    expect(method.inspect()).toEqual
      name: 'fetchLimit'
      kind: 'dynamic'
      bound: false
      parameters: []

    method = Method.fromMethodEntity environment.entities[3]
    expect(method.inspect()).toEqual
      name: 'do'
      kind: 'dynamic'
      bound: false
      parameters: ['it', 'again', 'options']

    method = Method.fromMethodEntity environment.entities[4]
    expect(method.inspect()).toEqual
      name: 'doWithoutSpace'
      kind: 'dynamic'
      bound: false
      parameters: ['it', 'again', 'options']

    method = Method.fromMethodEntity environment.entities[5]
    expect(method.inspect()).toEqual
      name: 'lets_do_it'
      kind: 'static'
      bound: false
      parameters: ['it', 'options']
