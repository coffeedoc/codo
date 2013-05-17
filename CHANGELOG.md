# Codo Changelog

## Version 1.7.0 - Mai 17, 2013

- [#105](https://github.com/netzpirat/codo/issues/105): Add support for closure like block comments. ([@stefi023][])

## Version 1.6.2 - Mai 13, 2013

- [#104](https://github.com/netzpirat/codo/issues/104): Ensure proper partial names on Windows.

## Version 1.6.1 - April 25, 2013

- [#101](https://github.com/netzpirat/codo/issues/101): Wrap text around table of contents. ([@wulftone][])

## Version 1.6.0 - March 25, 2013

- Detect project name from Git config when hosted on GitHub.
- [#97](https://github.com/netzpirat/codo/issues/97): Allow `@see` to reference properties.
- [#93](https://github.com/netzpirat/codo/issues/93): Fix classes that extends themselves.
- [#95](https://github.com/netzpirat/codo/issues/95): Allow objects to be documented as properties.
- [#96](https://github.com/netzpirat/codo/issues/96): Fix multi line tags.

## Version 1.5.6 - February 19, 2013

- [#90](https://github.com/netzpirat/codo/issues/90): Fix class name for global bound classes.
- Do not escape attributes to avoid escaped link slashes.

### Version 1.5.5 - December 20, 2012

- [#88](https://github.com/netzpirat/codo/issues/88): Virtual methods allowed to use parameters options

### Version 1.5.4 - December 20, 2012

- [#87](https://github.com/netzpirat/codo/issues/87): Virtual methods made to not affect (nor break) coverage percent.

### Version 1.5.3 - December 13, 2012

- [#86](https://github.com/netzpirat/codo/pull/86): Fix documentation coverage percentage.

## Version 1.5.2 - November 12, 2012

- [#82](https://github.com/netzpirat/codo/pull/82): Fix reserved method name parsing.
- [#83](https://github.com/netzpirat/codo/pull/83): Fix detecting the default project name.
- [#69](https://github.com/netzpirat/codo/pull/69): Fix link parsing for link text with a space.

## Version 1.5.1 - September 30, 2012

- Fix Node 0.6 compatibility.

## Version 1.5.0 - September 30, 2012

- [#65](https://github.com/netzpirat/codo/pull/65): Fix markdown spacing and line wrapping.
- [#77](https://github.com/netzpirat/codo/pull/77): Allow multiple types for simple "overload" cases.
- [#66](https://github.com/netzpirat/codo/pull/66): Add a link to the project README on top of the breadcrumb list.
- [#76](https://github.com/netzpirat/codo/pull/76): Add a `@throw` tag to define raised exceptions.
- [#69](https://github.com/netzpirat/codo/pull/69): Fix link parsing within a reference.
- [#78](https://github.com/netzpirat/codo/pull/78): Allow the name before the type for the `@option` tag.

## Version 1.4.4 - September 26, 2012

- [#75](https://github.com/netzpirat/codo/pull/75): Ignore command line params if codo has not been started directly. ([@vizio360][])

## Version 1.4.3 - September 24, 2012

- [#74](https://github.com/netzpirat/codo/issues/74): Use the method return when not set within a method overload. ([@PaulLeCam][])

## Version 1.4.2 - September 14, 2012

- [#71](https://github.com/netzpirat/codo/issues/71): Fix tag look ahead with non word characters.
- [#67](https://github.com/netzpirat/codo/issues/67): Input a file instead of a directory.
- [#70](https://github.com/netzpirat/codo/issues/70): Ensure deep property access doesn't stop class processing.
- [#69](https://github.com/netzpirat/codo/issues/69): Fix link parsing within a reference.
- [#65](https://github.com/netzpirat/codo/issues/65): Fix GitHub Flavored Markdown rendering around inline tags.

## Version 1.4.1 - September 8, 2012

- [#61](https://github.com/netzpirat/codo/issues/61): Allow instance variables to be marked as properties.
- [#62](https://github.com/netzpirat/codo/issues/62): Fix curly brace escaping when searching references.

## Version 1.4.0 - September 7, 2012

- [#64](https://github.com/netzpirat/codo/issues/64): Fix broken overload rendering.
- [#61](https://github.com/netzpirat/codo/issues/61): Detect Properties.
- [#64](https://github.com/netzpirat/codo/issues/64): Fix comment preprocessing by detect block comments that start and ends on the same line.
- [#57](https://github.com/netzpirat/codo/issues/57): Fix detection of standalone methods.
- [#62](https://github.com/netzpirat/codo/issues/62): Do not search for references within code blocks (escape {} by surround with backticks).
- [#63](https://github.com/netzpirat/codo/issues/63): Allow limited Markdown in `@return`, `@param`, `@option`, `@see`, `@author`, `@copyright`, `@note`, `@todo`, `@since`, `@version` and `@deprecated` tags.
- Improve GitHub Falvored Markdown compatibility

## Version 1.3.1 - September 4, 2012

- [#59](https://github.com/netzpirat/codo/pull/59): Fix Node < 0.8 compatibility.
- [#60](https://github.com/netzpirat/codo/pull/60): Add Streamline support by also parse `._coffee` files.

## Version 1.3.0 - September 3, 2012

- Show only tabs/list that aren't empty and detect the best initial view.
- Allow non-class methods and constants to be documented.
- [#58](https://github.com/netzpirat/codo/pull/58): Narrow constant regexp for comment conversion.

## Version 1.2.3 - August 24, 2012

- [#56](https://github.com/netzpirat/codo/pull/56): Mark the document as UTF-8. ([@alappe][])

## Version 1.2.2 - August 23, 2012

- [#55](https://github.com/netzpirat/codo/issues/55): Markdown Headings in Codo comments fixed.

## Version 1.2.1 - August 16, 2012

- [#39](https://github.com/netzpirat/codo/issues/39): Test alternative browsers.
- [#53](https://github.com/netzpirat/codo/issues/53): Large blank iframe shows up on Codo in Firefox.

## Version 1.2.0 - August 12, 2012

- Allow Codo tag syntax with curly braces instead of square brackets.
- [#52](https://github.com/netzpirat/codo/issues/52): Fix indented block comment parsing.

## Version 1.1.2 - August 10, 2012

- Detect `@return` tags without specified result type.
- [#51](https://github.com/netzpirat/codo/issues/51): Fix comment processing for methods without parameters.

## Version 1.1.1 - August 10, 2012

- [#50](https://github.com/netzpirat/codo/issues/50): Fix `@option` within `@overload` section.

## Version 1.1.0 - August 10, 2012

- Detect optimal projects defaults for source dirs, extra files and the readme.

## Version 1.0.1 - August 7, 2012

- Remove debug statement.  ([@netzpirat][])

## Version 1.0.0 - August 7, 2012

- Add option to add Google Analytics tracking code to the docs. ([@netzpirat][])
- Add API to get generated files, scripts and styles. ([@netzpirat][])
- Add API to set the breadcrumbs homepage on all pages. ([@netzpirat][])

## Version 0.9.1 - June 12, 2012

- [#49](https://github.com/netzpirat/codo/issues/49): Make compatible with Windows 7. ([@netzpirat][])

## Version 0.9.0 - June 12, 2012

- Make file paths relative. ([@netzpirat][])

## Version 0.8.3 - June 11, 2012

- Use walkdir instead of findit for Windows compatibility. ([@netzpirat][])

## Version 0.8.2 - June 10, 2012

- Make file access Windows compatible. ([@netzpirat][])

## Version 0.8.1 - June 5, 2012

- [#45](https://github.com/netzpirat/codo/issues/45): Parser ignores comments for functions w/ params & no whitespace. ([@inossidabile][])

## Version 0.8.0 - June 4, 2012

- Ensure that block style comments won't be touched. ([@netzpirat][])
- [#44](https://github.com/netzpirat/codo/issues/44): Enable users to diable singleline comment support ([@skabbes][])

## Version 0.7.1 - May 18, 2012

- [#43](https://github.com/netzpirat/codo/issues/43): Allow mixins' methods referencing. ([@inossidabile][])
- [#42](https://github.com/netzpirat/codo/issues/42): Empty name classes lead to failures. ([@inossidabile][])

## Version 0.7.0 - April 19, 2012

- [#38](https://github.com/netzpirat/codo/issues/38): Add a global fuzzy search. ([@netzpirat][])
- [#37](https://github.com/netzpirat/codo/issues/37): Start a local server. ([@netzpirat][])
- [#40](https://github.com/netzpirat/codo/issues/40): Fix asset path for extra files in subdirectories. ([@ryan-roemer][])

## Version 0.6.2 - April 4, 2012

- Don't not show the empty tab search window on start in Firefox. ([@netzpirat][])

## Version 0.6.1 - April 4, 2012

- Show external links in top level document to avoid `X-Frame-Options` blocking. ([@netzpirat][])
- Add support for keyboard navigation. ([@netzpirat][])
- Remove tree indention and show namespace of entities in the search result. ([@netzpirat][])

## Version 0.6.0 - April 3, 2012

- Implement `@method` tag.
- [#19](https://github.com/netzpirat/codo/issues/19):  Implement `@overload` tag. ([@netzpirat][])
- Add `@concern` as mixin specialization with defined class and instance methods. ([@netzpirat][])
- [#17](https://github.com/netzpirat/codo/issues/17):  Implement `@param` reference tags. ([@netzpirat][])
- [#36](https://github.com/netzpirat/codo/issues/36):  Make the example title optional. ([@netzpirat][])
- Rename `@module` to `@mixin` to avoid confusion with Node.js modules. ([@netzpirat][])
- [#30](https://github.com/netzpirat/codo/issues/30):  Make the frames view the default. ([@netzpirat][])
- [#35](https://github.com/netzpirat/codo/issues/35):  Links aren't working on Class/Module List dropdown for parent nodes. ([@netzpirat][])
- [#15](https://github.com/netzpirat/codo/issues/15): Generate a TOC for file contents. ([@netzpirat][])
- Detect inner (nested) classes. ([@netzpirat][])
- [#34](https://github.com/netzpirat/codo/issues/34): Fix label assignment in references. ([@netzpirat][])
- [#28](https://github.com/netzpirat/codo/pull/28): Description for `@param` and `@option` is now optional. ([@mattijs][])

## Version 0.5.0 - March 15, 2012

- [#27](https://github.com/netzpirat/codo/pull/27): Added support for `@copyright` tag. ([@mattijs][])
- [#25](https://github.com/netzpirat/codo/issues/25): Exclude functions internal to the class closure. ([@netzpirat][])

## Version 0.4.2 - February 27, 2012

- [#24](https://github.com/netzpirat/codo/pull/24): Fix private method filter. ([@Squeegy][])

## Version 0.4.1 - February 26, 2012

- Make the doc reference resolver more fail safe. ([@netzpirat][])

## Version 0.4.0 - February 26, 2012

- [#20](https://github.com/netzpirat/codo/issues/20): Parse class/method references in the docs. ([@netzpirat][])
- [#18](https://github.com/netzpirat/codo/issues/18): Support the `@see` tag. ([@netzpirat][])
- [#22](https://github.com/netzpirat/codo/issues/22): Add a `Private` badge to private classes. ([@netzpirat][])
- [#21](https://github.com/netzpirat/codo/issues/21): Filter private methods when to explicit set to include. ([@netzpirat][])
- [#14](https://github.com/netzpirat/codo/issues/14): Make the class list a tree. ([@netzpirat][])

## Version 0.3.0 - February 20, 2012

- [#11](https://github.com/netzpirat/codo/issues/11): Add frame based sidebar. ([@netzpirat][])
- [#12](https://github.com/netzpirat/codo/issues/12): Rename class index so it can be pushed to GithHub pages. ([@netzpirat][])
- [#10](https://github.com/netzpirat/codo/issues/10): Improve the class comment section. ([@inossidabile][])
- [#9](https://github.com/netzpirat/codo/issues/9): Real CoffeeScript code highlighting. ([@inossidabile][], Highlighter by [@dnagir][])
- [#8](https://github.com/netzpirat/codo/issues/8): Improve comment parsing with dots. ([@inossidabile][])
- [#7](https://github.com/netzpirat/codo/issues/7): Make `@return` description optional. ([@inossidabile][])
- [#5](https://github.com/netzpirat/codo/issues/5): Support `@private` option for classes. ([@inossidabile][])

## Version 0.2.1 - February 17, 2012

- Fix wrong path to NPM package binary. ([@netzpirat][])

## Version 0.2.0 - February 17, 2012

- First public release. ([@netzpirat][])

## Version 0.1.0 - February 14, 2012

- Initial release to reserve the NPM name. ([@netzpirat][])

[@alappe]: https://github.com/alappe
[@dnagir]: https://github.com/dnagir
[@inossidabile]: https://github.com/inossidabile
[@mattijs]: https://github.com/mattijs
[@netzpirat]: https://github.com/netzpirat
[@PaulLeCam]: https://github.com/PaulLeCam
[@ryan-roemer]: https://github.com/ryan-roemer
[@skabbes]: https://github.com/skabbes
[@stefi023]: https://github.com/stefi023
[@Squeegy]: https://github.com/Squeegy
[@vizio360]: https://github.com/vizio360
[@wulftone]: https://github.com/wulftone
