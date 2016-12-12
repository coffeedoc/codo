Markdown = require '../../../lib/tools/markdown'
jsdiff      = require 'diff'

describe 'Markdown', ->

  describe 'Input sanitizing', ->
    it "won't allow javascript:.* links", ->
      markdown = "x[URL](javascript&#58document;alert&#40;1&#41;)x"
      expect(Markdown.convert(markdown, true)).toEqual("xx ")

  describe 'limited markdown conversion', ->
    limit = true

    it 'removes non-inline tags', ->
      markdown = """
      # A markdown list
      - THING_1
      - THING_2 - A long, mulitline
        list element
      """

      expect(Markdown.convert(markdown, limit)).toEqual("""
      A markdown list 
      THING_1
      THING_2 - A long, mulitline
      list element


      """)
