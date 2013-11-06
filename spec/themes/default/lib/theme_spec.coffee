OS          = require 'os'
Path        = require 'path'
Environment = require '../../../../lib/environment'
Theme       = require '../../../../themes/default/lib/theme'
rimraf      = require 'rimraf'

describe 'Theme', ->
  beforeEach ->
    @output = Path.join OS.tmpdir(), 'codo_theme_spec'
    rimraf.sync @output

  it 'generates', ->
    environment = new Environment output: @output

    environment.readExtra 'spec/_templates/example/CHANGELOG'
    environment.readExtra 'spec/_templates/example/README.md', true

    environment.readCoffee 'spec/_templates/example/src/over_documented_class.coffee'
    environment.readCoffee 'spec/_templates/example/src/over_documented_mixin.coffee'

    environment.linkify()

    Theme.compile(environment)