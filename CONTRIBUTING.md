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

## Feature freeze

Codo has initially started as simple experiment to document the CoffeeScript class system and has quickly evolved to a
general documentation generator that supports many best practices that aren't part of CoffeeScript. I'd like to
continue extending Codo, but the code base has grown too fast and needs some architectural refactorings before more
features can be added.

**Until the architectural refactorings have been finished, no more features will be added to Codo.**

Planned tasks for Codo 2:

* Use CoffeeScript Redux for parsing.
* Remove the comment conversion and add comments to the CoffeeScript Redux parser instead.
* Switch from class to function focused approach.
* Abstract token detection into a tree walker.
* Separate structural analysis from the generator and referencer.

Thanks for understanding.
