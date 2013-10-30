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
    environment = new Environment destination: @destination

    environment.readExtra 'spec/_templates/extras/README'
    environment.readExtra 'spec/_templates/extras/README.md', true

    environment.readCoffee 'spec/_templates/examples/animal.coffee'
    environment.readCoffee 'spec/_templates/examples/lion.coffee'
    environment.readCoffee 'spec/_templates/examples/angry_animal.coffee'

    environment.linkify()

    Theme.compile(environment)