# Codo - the CoffeeScript API documentation generator
#
# # Header 1
#
# This is a paragraph.
#
# ## Header 2
#
# This is a paragraph.
#
# ### Header 3
#
# This is a paragraph.
#
# #### Header 4
#
# This is a paragraph.
#
# ##### Header 5
#
# This is a paragraph.
#
# ###### Header 6
#
# This is a paragraph.
#
# @abstract _Template methods_ must be implemented
# @note Also notes have _now_ <del>Markdown</del>
# @todo Allow **markdown** in todos
#
# @author Mickey
# @author **Donald**
# @copyright _No Copyright_
# @since **1.0.0**
# @version _1.1.0_
# @deprecated **nobody** uses this
#
class TestMarkdownDocumentation

  #
  # @see #another for _more_ information
  # @param a [Hash] this _must_ be supplied
  # @option a [String] prop this is the **URL**
  # @return [String] something **very** important
  #
  test: (a) ->

  #
  # @param [String] a this _must_ be supplied
  # @return A _very_ nice thing
  #
  another: (a) ->
