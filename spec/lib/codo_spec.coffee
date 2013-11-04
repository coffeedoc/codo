Path = require 'path'
Codo = require '../../lib/codo'

describe 'Codo', ->

  it 'parses project', ->
    environment = Codo.parseProject(Path.join __dirname, '../_templates/example')
    
    expect(environment.allFiles().map (file) -> file.inspect().file).toEqual [
      'src/angry_animal.coffee', 'src/animal.coffee', 'src/lion.coffee' 
    ]

    expect(environment.allExtras()).toEqual [
      'CHANGELOG', 'README.md'
    ]

    expect(environment.options.readme).toEqual 'README.md'