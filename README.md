# Codo [![Build Status](https://secure.travis-ci.org/netzpirat/codo.png)](http://travis-ci.org/netzpirat/codo.png)

Codo is a [CoffeeScript](http://coffeescript.org/) API documentation generator, similar to [YARD](http://yardoc.org/).
Its generated documentation is focused on CoffeeScript class syntax for classical inheritance and not for JavaScript's
prototypal inheritance.

## Codo in Action

You can browse the [Codo documentation](http://netzpirat.github.com/codo) and the
[Haml-Coffee documentation](http://9elements.github.com/haml-coffee/) to see Codo in Action.

## Installation

Codo is available in NPM and can be installed with:

```bash
$ npm install codo
```

## Tags

Codo comments are rendered as [GitHub Flavored Markdown](http://github.github.com/github-flavored-markdown/)
and can be tagged to add more structured information to class and method comments.

_Tags can take multiple lines, just indent subsequent lines by two spaces._

### Overview

<table>
  <thead>
    <tr>
      <td><strong>Tag format</strong></td>
      <td><strong>Multiple occurrences</strong></td>
      <td><strong>Class level</strong></td>
      <td><strong>Method level</strong></td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>@abstract</strong> (message)</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@author</strong> name</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@deprecated</strong></td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@example</strong> (title)<br/>&nbsp;&nbsp;Code</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@note</strong> message</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@option</strong> option [type] name description</td>
      <td>&#10004;</td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td>
        <strong>@param</strong> [type] name description<br/>
        <strong>@param</strong> name [type] description<br/>
      </td>
      <td>&#10004;</td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@private</strong></td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@return</strong> [type] description</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@since</strong> version</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@todo</strong> message</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@version</strong> version</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
  </tbody>
<table>

### Example

```CoffeeScript
# Base class for all animals.
#
# @note This is not used for codo, its purpose is to show
#   all possible tags within a class.
#
# @todo Provide more examples
#
# @example How to subclass an animal
#   class Lion extends Animal
#     move: (direction, speed): ->
#
# @abstract Each animal implementation must inherit from {Animal}
#
# @author Michael Kessler
# @deprecated This class is not used anymore
# @version 0.2.0
# @since 0.1.0
#
class Example.Animal

  # The Answer to the Ultimate Question of Life, the Universe, and Everything
  @ANSWER = 42

  # Construct a new animal.
  #
  # @todo Clean up
  # @param [String] name the name of the animal
  # @param [Date] birthDate when the animal was born
  #
  constructor: (@name, @birthDate = new Date()) ->

  # Move the animal.
  #
  # @example Move an animal
  #   new Lion('Simba').move('south', 12)
  #
  # @abstract
  # @param [Object] options the moving options
  # @option options [String] direction the moving direction
  # @option options [Number] speed the speed in mph
  #
  move: (options = {}) ->

  # Copulate another animal.
  #
  # @note Don't take it seriously
  #
  # @private
  # @author Michael Kessler
  # @param [Animal] animal the partner animal
  # @return [Boolean] true when success
  # @deprecated Do not copulate
  # @version 0.2.0
  # @since 0.1.0
  #
  copulate: (animal) =>

  # Moves all animal into the ark.
  #
  # @return [Boolean] true when all in Ark
  #
  @enterArk: ->
```

## Generate

After the installation you will have a `codo` binary that can be used to generate the documentation recursively for all
CoffeeScript files within a directory.

```bash
$ codo --help
Usage: codo [options] [source_files [- extra_files]]

Options:
  -r, --readme      The readme file used   [default: "README.md"]
  -q, --quiet       Show no warnings       [boolean]  [default: false]
  -o, --output-dir  The output directory   [default: "./doc"]
  -v, --verbose     Show parsing errors    [boolean]  [default: false]
  -h, --help        Show the help
  --private         Show private methods
  --title                                  [default: "CoffeeScript API Documentation"]
```

### Project defaults

You can define your project defaults by write your command line options to a `.codoopts` file:

```bash
--readme     README.md
--title      "Codo Documentation"
--private
--quiet
--output-dir ./doc
./src
-
LICENSE
CHANGELOG.md
```

## Reporting issues

Issues hosted at [GitHub Issues](https://github.com/netzpirat/codo/issues).

The codo specs are template based, so make sure you provide a code snippet that can be added as failing spec to the
project when reporting an issue with parsing your CoffeeScript code.

_You can check if some parsing errors have occured by running codo in verbose mode._

## Development

Source hosted at [GitHub](https://github.com/netzpirat/codo).

Pull requests are very welcome! Please try to follow these simple rules if applicable:

* Please create a topic branch for every separate change you make.
* Make sure your patches are well tested.
* Update the documentation.
* Update the README.
* Update the CHANGELOG for noteworthy changes.
* Please **do not change** the version number.

## Acknowledgment

- [Jeremy Ashkenas](https://github.com/jashkenas) for [CoffeeScript](http://coffeescript.org/), that mighty language
that compiles to JavaScript and makes me enjoy JavaScript development.
- [Loren Segal](https://github.com/lsegal) for creating YARD and giving me the perfect documentation syntax for
dynamic programming languages.

## Alternatives

* [Docco](http://jashkenas.github.com/docco/) is a quick-and-dirty, literate-programming-style documentation generator.
* [CoffeeDoc](https://github.com/omarkhan/coffeedoc) an alternative API documentation generator for CoffeeScript.
* [JsDoc](https://github.com/micmath/jsdoc) an automatic documentation generator for JavaScript.
* [Dox](https://github.com/visionmedia/dox) JavaScript documentation generator for node using markdown and jsdoc.

## Author

* [Michael Kessler](https://github.com/netzpirat) ([@netzpirat](http://twitter.com/#!/netzpirat))

Development is sponsored by [mksoft.ch](https://mksoft.ch).

## License

(The MIT License)

Copyright (c) 2012 Michael Kessler

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
