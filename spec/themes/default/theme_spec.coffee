OS          = require 'os'
Path        = require 'path'
Environment = require '../../../lib/environment'
Theme       = require '../../../themes/default/theme'
rimraf      = require 'rimraf'

describe 'Theme', ->
  beforeEach ->
    @destination = Path.join OS.tmpdir(), 'codo_theme_spec'
    rimraf.sync @destination

  it 'generates', ->
    Theme.compile(new Environment destination: @destination)
    console.log @destination