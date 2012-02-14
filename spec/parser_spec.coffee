fs     = require 'fs'
findit = require('findit')
Parser = require('../lib/parser')

beforeEach ->
  @addMatchers
    toBeCompiledTo: (expected) ->
      @message = -> @actual.report
      @actual.generated is expected

for filename in findit.sync './spec/templates'
  if filename.match /\.coffee$/
    source = fs.readFileSync filename, 'utf8'
    expected = JSON.stringify(JSON.parse(fs.readFileSync filename.replace(/\.coffee$/, '.json'), 'utf8'), null, 2)

    do (source, expected, filename) ->

      describe "The CoffeeScript file #{ filename }", ->
        it 'parses correctly to JSON', ->
          parser = new Parser()
          tokens = parser.parseContent source, filename
          generated = JSON.stringify(parser.toJSON(), null, 2)

          report = "\n-------------------- CoffeeScript ----------------------\n"
          report += source
          report += "\n------------- Preprocessed CoffeeScript-----------------\n"
          report += parser.convertComments(source)
          report += "\n----------------------- Nodes --------------------------"
          report += tokens.toString()
          report += "\n-------------------- Parsed JSON ------------------------\n"
          report += generated
          report += "\n------------------- Expected JSON ---------------------\n"
          report += expected
          report += "\n-------------------------------------------------------\n"

          expect({
            generated: generated
            report: report.split('\n').join('\n    ')
          }).toBeCompiledTo(expected)
