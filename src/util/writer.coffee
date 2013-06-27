fs         = require 'fs'
path       = require 'path'
mkdirp     = require 'mkdirp'

# The writer knows how to write files in the user's filesystem.
#
module.exports = class Writer
  # Construct a writer
  #
  # @param [Object] options the options
  #
  constructor: (@options) ->
    @fileCallback = null
  
  # Configures the writer to call a function instead of creating a file
  #
  # @param [Function] callback called with each file's contents and name
  #
  setCallback: (callback) ->
    @fileCallback = callback

  # Writes a file to the user's filesystem.
  #
  # @param [String] content the data to be written to the file
  # @param [String] filename the output file name
  #
  output: (content, filename) ->
    # Callback generated content
    if @fileCallback
      @fileCallback(filename, html)

    # Write to file system
    else
      file = path.join @options.output, filename
      dir  = path.dirname(file)
      mkdirp dir, (err) ->
        if err
          console.error "[ERROR] Cannot create directory #{ dir }: #{ err }"
        else
          fs.writeFile file, html

   return
