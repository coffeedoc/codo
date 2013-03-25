# Contribute to Codo

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
