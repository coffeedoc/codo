(function() {
  var Node;

  module.exports = Node = (function() {

    function Node() {}

    Node.prototype.findAncestor = function(type, node) {
      if (node == null) node = this.node;
      if (node.ancestor) {
        if (node.ancestor.constructor.name === type) {
          return node.ancestor;
        } else {
          return this.findAncestor(type, node.ancestor);
        }
      } else {
        return;
      }
    };

    return Node;

  })();

}).call(this);
