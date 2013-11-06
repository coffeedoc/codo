Path = require 'path'
Codo = require '../../lib/codo'

describe 'Codo', ->

  it 'parses project', ->
    environment = Codo.parseProject(Path.join __dirname, '../_templates/example')
    
    expect(environment.allFiles().map (file) -> file.inspect().file).toEqual [
      'src/angry_animal.coffee',
      'src/animal.coffee',
      'src/lion.coffee',
      'src/over_documented_class.coffee',
      'src/over_documented_mixin.coffee'
    ]

    expect(environment.allExtras().map (e) -> e.name).toEqual [
      'README.md', 'CHANGELOG'
    ]

    expect(environment.options.readme).toEqual 'README.md'