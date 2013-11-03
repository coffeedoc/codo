OS          = require 'os'
Path        = require 'path'
Environment = require '../../../../lib/environment'
Theme       = require '../../../../themes/default/lib/theme'
rimraf      = require 'rimraf'

describe 'Theme', ->
  beforeEach ->
    @destination = Path.join OS.tmpdir(), 'codo_theme_spec'
    rimraf.sync @destination

  it 'generates', ->
    console.log @destination

    environment = new Environment destination: @destination

    environment.readExtra 'spec/_templates/example/CHANGELOG'
    environment.readExtra 'spec/_templates/example/README.md', true

    environment.readCoffee 'spec/_templates/example/src/animal.coffee'
    environment.readCoffee 'spec/_templates/example/src/lion.coffee'
    environment.readCoffee 'spec/_templates/example/src/angry_animal.coffee'

    environment.linkify()

    Theme.compile(environment)