# Codo [![Build Status](https://secure.travis-ci.org/netzpirat/codo.png)](http://travis-ci.org/netzpirat/codo)

Codo is a [CoffeeScript](http://coffeescript.org/) API documentation generator, similar to [YARD](http://yardoc.org/).
Its generated documentation is focused on CoffeeScript class syntax for classical inheritance.

## Features

* Detects classes, methods, constants, mixins & concerns.
* Many tags to add semantics to your code.
* Generates a nice site to browse your code documentation in various ways.
* Documentation generation and hosting as a service on [CoffeeDoc.info](http://coffeedoc.info).

## Codo in action

Annotate your source with Codo tags to add semantic information to your code. It looks like this:

```CoffeeScript
# Base class for all animals.
#
# @example How to subclass an animal
#   class Lion extends Animal
#     move: (direction, speed): ->
#
class Example.Animal

  # The Answer to the Ultimate Question of Life, the Universe, and Everything
  @ANSWER = 42

  # Construct a new animal.
  #
  # @param [String] name the name of the animal
  # @param [Date] birthDate when the animal was born
  #
  constructor: (@name, @birthDate = new Date()) ->

  # Move the animal.
  #
  # @example Move an animal
  #   new Lion('Simba').move('south', 12)
  #
  # @param [Object] options the moving options
  # @option options [String] direction the moving direction
  # @option options [Number] speed the speed in mph
  #
  move: (options = {}) ->
```

Then generate the documentation with the `codo` command line tool. You can browse some
generated Codo documentation on [CoffeeDoc.info](http://coffeedoc.info) to get a feeling how you can navigate in various
ways through your code layers.

In the `Example` namespace you'll find some classes and mixins that makes absolutely no sense, its purpose is only to
show the many features Code offers.

## Installation

Codo is available in NPM and can be installed with:

```bash
$ npm install -g codo
```

Please have a look at the [CHANGELOG](https://github.com/netzpirat/codo/blob/master/CHANGELOG.md) when upgrading to a
newer Codo version with `npm update`.

## Tags

You have to annotate your code with Codo tags to give it some meaning to the parser that generates the documentation.
Each tag starts with the `@` sign followed by the tag name. See the following overview for a minimal description of all
available tags. Most tags are self-explaining and the one that aren't are described afterwards in more detail.

Tags can take multiple lines, just indent subsequent lines by two spaces.

### Overview

The following table shows the list of all available tags in alphabetical order with its expected options. An option in
parenthesis is optional and the square brackets are part of the Codo tag format and must actually be written. Some tags
can be defined multiple times and they can be applied to different contexts, either in the comment for a class, a
comment for a mixin or in a method comment.

<table>
  <thead>
    <tr>
      <td><strong>Tag format</strong></td>
      <td><strong>Multiple occurrences</strong></td>
      <td><strong>Classes</strong></td>
      <td><strong>Mixins</strong></td>
      <td><strong>Methods</strong></td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>@abstract</strong> (message)</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@author</strong> name</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@concern</strong> mixin</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@copyright</strong> name</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@deprecated</strong></td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@example</strong> (title)<br/>&nbsp;&nbsp;Code</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@extend</strong> mixin</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@include</strong> mixin</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@note</strong> message</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@method</strong> signature<br/>&nbsp;&nbsp;Method tags</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@mixin</strong> version</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>@option</strong> option [type] name description</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@overload</strong> signature<br/>&nbsp;&nbsp;Method tags</td>
      <td>&#10004;</td>
      <td></td>
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
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@private</strong></td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@property</strong> [type] description</td>
      <td></td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@return</strong> [type] description</td>
      <td></td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@see</strong> link/reference</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@since</strong> version</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@throw</strong> message</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@todo</strong> message</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
    <tr>
      <td><strong>@version</strong> version</td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
    </tr>
  </tbody>
</table>

### Alternative syntax

You can also use curly braces instead of square brackets if you prefer:

```CoffeeScript
# Move the animal.
#
# @example Move an animal
#   new Lion('Simba').move('south', 12)
#
# @param {Object} options the moving options
# @option options {String} direction the moving direction
# @option options {Number} speed the speed in mph
#
move: (options = {}) ->
```

It's also possible to use [CoffeeScript block comments](http://coffeescript.org/#strings) instead of the normal
comments. If you solely use block comments, you may want to use the `--cautious` flag to disable the internal comment
conversion.

```CoffeeScript
###
Move the animal.

@example Move an animal
  new Lion('Simba').move('south', 12)

@param [Object] options the moving options
@option options [String] direction the moving direction
@option options [Number] speed the speed in mph
###
move: (options = {}) ->
```

If you want to compile your JavaScript with Google Closure and make use of the special block comments with an asterisk,
you want to use the `--closure` flag so that Codo ignores the asterisk.

### Parameters

There are two different format recognized for your parameters, so you can chose your favorite. This one is with the
parameter after the parameter type:

```CoffeeScript
# Feed the animal
#
# @param [World.Food] food the food to eat
# @param [Object] options the feeding options
# @option options [String] time the time to feed
#
feed: (food) ->
```

And this one with the name before the type:

```CoffeeScript
# Feed the animal
#
# @param food [World.Food] the food to eat
# @param options [Object] the feeding options
# @option options time [String] the time to feed
#
feed: (food) ->
```

The parameter type can contain multiple comma separated types:

```CoffeeScript
# Feed the animal
#
# @param [String, Char] input
# @return [Integer, Float] output
#
do: (input) ->
```

Each known type will be automatically linked.

### Options

If you have an object as parameter and you like to defined the accepted properties as options to the method, you can
use the `@options` tag:


```CoffeeScript
# Feed the animal
#
# @param [Object] options the calculation options
# @option options [Integer] age the age of the animal
# @option options [Integer] weight the weight of the animal
#
expectationOfLife: (options) ->
```

The first parameter to the option tag is the parameter name it describes, followed by the parameter type, name and
description.

### Types

The object types for the `@param`, `@option` and `@return` tags are parsed for known classes or mixins and linked. You
can also define types for Arrays with:

```CoffeeScript
#
# @param [World.Region] region the region of the herd
# @return [Array<Animals>] the animals in the herd
#
getHerdMembers: (regions) ->
```

### Properties

You can mark an instance variable as property of the class by using the `@property` tag like:

```CoffeeScript
class Person

  # @property [Array<String>] the nicknames
  nicknames: []
```

In addition, the following properties pattern is detected:

```CoffeeScript
class Person

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  # @property [String] The person name
  get name: -> @_name
  set name: (@_name) ->

  # The persons age
  get age: -> @_age
```

If you follow this convention, they will be shown in the generated documentation with its read/write status shown. To
specify type of the property, use the `@property` tag.

### Method overloading

If you allow your method to take different parameters, you can describe the method overloading with the `@overload` tag:

```CoffeeScript
# This is a generic Store set method.
#
# @overload set(key, value)
#   Sets a value on key
#   @param [Symbol] key describe key param
#   @param [Object] value describe value param
#
# @overload set(value)
#   Sets a value on the default key `:foo`
#   @param [Object] value describe value param
#   @return [Boolean] true when success
#
set: (args...) ->
```

The `@overload` tag must be followed by the alternative method signature that will appear in the documentation, followed
by any method tag indented by two spaces.

### Virtual methods

If you copy over functions from other objects without using mixins or concerns, you can add documentation for this
virtual (or dynamic) method with the `@method` tag:

```CoffeeScript
# This class has a virtual method, that doesn't
# exist in the source but appears in the documentation.
#
# @method #set(key, value)
#   Sets a value on key
#   @param [Symbol] key describe key param
#   @param [Object] value describe value param
#
class VirtualMethods
```

The `@method` tag must be followed by the method signature that will appear in the documentation, followed
by any method tag indented by two spaces. The difference to the `@overload` tag beside the different context is that
the signature should contain either the instance prefix `#` or the class prefix `.`.

### Mixins

It's common practice to mix in objects to share common logic when inheritance is not suited. You can read
more about mixins in the
[The Little Book on CoffeeScript](http://arcturo.github.com/library/coffeescript/03_classes.html).

Simply mark any plain CoffeeScript object with the `@mixin` tag to have a mixin page generated that supports many tags:

```CoffeeScript
# Speed calculation for animal.
#
# @mixin
# @author Rockstar Ninja
#
Example.Animal.Speed =

  # Get the distance the animal will put back in a certain time.
  #
  # @param [Integer] time Number of seconds
  # @return [Integer] The distance in miles
  #
  distance: (time) ->
```

Next mark the target object that includes one or multiple mixins:

```CoffeeScript
# @include Example.Animal.Speed
class Example.Animal.Lion
```

and you'll see the mixin methods appear as instance methods in the lion class documentation.
You can also extend a mixin:

```CoffeeScript
# @extend Example.Animal.Speed
class Example.Animal.Lion
```

so its methods will show up as class methods.

#### Concerns

A concern is a combination of two mixins, one for instance methods and the other for class methods and it's
automatically detected when a mixin has both a `ClassMethods` and an `InstanceMethods` property:

```CoffeeScript
# Speed calculations for animal.
#
# @mixin
# @author Rockstar Ninja
#
Example.Animal.Speed =

  InstanceMethods:

    # Get the distance the animal will put back in a certain time.
    #
    # @param [Integer] time Number of seconds
    # @return [Integer] The distance in miles
    #
    distance: (time) ->

  ClassMethods:

    # Get the common speed of the animal in MPH.
    #
    # @param [Integer] age The age of the animal
    # @return [Integer] The speed in MPH
    #
    speed: (age) ->
```

You can use `@concern` to include and extend the correspondent properties:

```CoffeeScript
# @concern Example.Animal.Speed
class Example.Animal.Lion
```

### Non-class methods and variables

You can also document your non-class, top level functions and constants within a file. As soon Codo detects these types
within a file, it will be added to the file list and you can browse your file methods and constants.

## Text processing

### GitHub Flavored Markdown

Codo class, mixin and method documentation and extra files written in
[Markdown](http://daringfireball.net/projects/markdown/) syntax are rendered as full
[GitHub Flavored Markdown](http://github.github.com/github-flavored-markdown/).

The `@return`, `@param`, `@option`, `@see`, `@author`, `@copyright`, `@note`, `@todo`, `@since`, `@version` and
`@deprecated` tags rendered with a limited Markdown syntax, which means that only inline elements will be returned.

### Automatically link references

Codo comments and all tag texts will be parsed for references to other classes, methods and mixins, and are automatically
linked. The reference searching will not take place within code blocks, thus you can avoid reference searching errors
by surround your code block that contains curly braces with backticks.

There are several ways of link types supported and all can take an optional label after the link.

* Normal URL links: `{http://coffeescript.org/}` or `{http://coffeescript.org/ Try CoffeeScript}`
* Link to a class or mixin: `{Animal.Lion}` or `{Animal.Lion The might lion}`
* Direct link to an instance method: `{Animal.Lion#walk}` or `{Animal.Lion#walk The lion walks}`
* Direct link to a class method: `{Animal.Lion.constructor}` or `{Animal.Lion.constructor} A new king was born`

If you are referring to a method within the same class, you can omit the class name: `{#walk}`.

The `@see` tag supports the same link types, just without the curly braces:

```CoffeeScript
@see http://en.wikipedia.org/wiki/Lion The wikipedia page about lions
```

## Generate

After the installation you will have a `codo` binary that can be used to generate the documentation recursively for all
CoffeeScript files within a directory.

```bash
$ codo --help
Usage: codo [options] [source_files [- extra_files]]

Options:
  -r, --readme      The readme file used                                [default: "README.md"]
  -n, --name        The project name used                               [default: "Codo"]
  -q, --quiet       Show no warnings                                    [boolean]  [default: false]
  -o, --output-dir  The output directory                                [default: "./doc"]
  -a, --analytics   The Google analytics ID                             [default: false]
  -v, --verbose     Show parsing errors                                 [boolean]  [default: false]
  -d, --debug       Show stacktraces and converted CoffeeScript source  [boolean]  [default: false]
  -h, --help        Show the help
  --cautious        Don't attempt to parse singleline comments          [boolean]  [default: false]
  --closure         Try to parse "google closure like" block comments   [boolean]  [default: false]
  -s, --server      Start a documentation server
  --private         Show private methods                                [boolean]  [default: true]
  --title                                               [default: "CoffeeScript API Documentation"]
```

Codo wants to be smart and tries to detect the best default settings for the sources, the readme, the extra files and
the project name, so the above defaults may be different on your project.

### Project defaults

You can define your project defaults by write your command line options to a `.codoopts` file:

```bash
--name       "Codo"
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

Put each option flag on a separate line, followed by the source directories or files, and optionally any extra file that
should be included into the documentation separated by a dash (`-`). If your extra file has the extension `.md`, it'll
be rendered as Markdown.

## Keyboard navigation

You can quickly search and jump through the documentation by using the fuzzy finder dialog:

* Open fuzzy finder dialog: `Ctrl-T`

In frame mode you can toggle the list naviation frame on the left side:

* Toggle list view: `Ctrl-L`

You can focus a list in frame mode or toggle a tab in frameless mode:

* Class list: `Ctrl-C`
* Mixin list: `Ctrl-I`
* File list: `Ctrl-F`
* Method list: `Ctrl-M`
* Extras list: `Ctrl-E`

You can focus and blur the search input:

* Focus search input: `Ctrl-S`
* Blur search input: `Esc`

In frameless mode you can close the list tab:

* Close list tab: `Esc`

## Report issues

Issues hosted at [GitHub Issues](https://github.com/netzpirat/codo/issues).

The Codo specs are template based, so make sure you provide a code snippet that can be added as failing spec to the
project when reporting an issue with parsing your CoffeeScript code.

_You can check if some parsing errors have occurred by running Codo in verbose mode._

## Development

Source hosted at [GitHub](https://github.com/netzpirat/codo).

Pull requests are very welcome! Please try to follow these simple rules if applicable:

* Please create a topic branch for every separate change you make.
* Make sure your patches are well tested.
* Update the documentation.
* Update the README.
* Update the CHANGELOG for noteworthy changes.
* Please **do not change** the version number.

## Features freeze

Codo has initially started as simple experiment to document the CoffeeScript class system and has quickly evolved to a
general documentation generator that supports many best practices that aren't part of CoffeeScript. Since every code
combination needs to be explicit detected and converted into an internal representation, it's a huge effort to support
everything that is possible with CoffeeScript. I've already implemented many features that I don't need for myself, and
since CoffeeScript is so damn flexible and powerful, many needs aren't covered yet.

**Since I have many other OSS projects I'd like to maintain and also enjoy my family in real life, I'm unable to add new
features to Codo for now. If you like to have a new feature in Codo, you need to implement it on your own and if you
open a pull-request, I'll happily assist you to find your way through the code base.**

Thanks for understanding.

## Acknowledgment

- [Jeremy Ashkenas](https://github.com/jashkenas) for [CoffeeScript](http://coffeescript.org/), that mighty language
that compiles to JavaScript and makes me enjoy JavaScript development.
- [Loren Segal](https://github.com/lsegal) for creating YARD and giving me the perfect documentation syntax for
dynamic programming languages.
- [Stratus Editor](https://github.com/stratuseditor) for open sourcing their [fuzzy filter](https://github.com/stratuseditor/fuzzy-filter).

## Alternatives

* [Docco](http://jashkenas.github.com/docco/) is a quick-and-dirty, literate-programming-style documentation generator.
* [CoffeeDoc](https://github.com/omarkhan/coffeedoc) an alternative API documentation generator for CoffeeScript.
* [JsDoc](https://github.com/micmath/jsdoc) an automatic documentation generator for JavaScript.
* [Dox](https://github.com/visionmedia/dox) JavaScript documentation generator for node using markdown and jsdoc.

## Author

* [Michael Kessler](https://github.com/netzpirat) ([@netzpirat](http://twitter.com/#!/netzpirat), [mksoft.ch](https://mksoft.ch))

## Contributors

* [Boris Staal](https://github.com/inossidabile) ([@_inossidabile](http://twitter.com/#!/_inossidabile))
* [Mattijs Hoitink](https://github.com/mattijs)

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
