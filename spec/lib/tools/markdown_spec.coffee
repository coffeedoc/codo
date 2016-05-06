Markdown = require '../../../lib/tools/markdown'
jsdiff      = require 'diff'

describe 'Markdown', ->
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
