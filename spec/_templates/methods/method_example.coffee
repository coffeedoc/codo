class TestExample

  # @example Run generation
  #   codo = require 'codo'
  #
  #   file = (filename, content) ->
  #     console.log "New file %s with content %s", filename, content
  #
  #   done = (err) ->
  #     if err
  #       console.log "Cannot generate documentation:", err
  #     else
  #       console.log "Documentation generated"
  #
  #   codo.run file, done
  run: ->
