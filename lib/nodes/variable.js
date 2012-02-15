(function() {
  var Doc, Variable;

  Doc = require('./doc');

  module.exports = Variable = (function() {

    function Variable(node, clazz, comment) {
      this.node = node;
      this.clazz = clazz != null ? clazz : false;
      if (comment == null) comment = null;
      this.getName();
      this.doc = new Doc(comment);
    }

    Variable.prototype.getType = function() {
      if (!this.type) this.type = this.clazz ? 'class' : 'instance';
      return this.type;
    };

    Variable.prototype.isConstant = function() {
      if (!this.constant) this.constant = /[A-Z_-]/.test(this.getName());
      return this.constant;
    };

    Variable.prototype.getDescription = function() {};

    Variable.prototype.getName = function() {
      var prop, _i, _len, _ref;
      if (!this.name) {
        this.name = this.node.variable.base.value;
        _ref = this.node.variable.properties;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          prop = _ref[_i];
          this.name += "." + prop.name.value;
        }
        if (/^this\./.test(this.name)) {
          this.name = this.name.substring(5);
          this.type = 'class';
        }
      }
      return this.name;
    };

    Variable.prototype.getValue = function() {
      if (!this.value) {
        this.value = this.node.value.base.compile({
          indent: ''
        });
      }
      return this.value;
    };

    Variable.prototype.toJSON = function() {
      var json;
      json = {
        doc: this.doc,
        type: this.getType(),
        constant: this.isConstant(),
        name: this.getName(),
        value: this.getValue()
      };
      return json;
    };

    return Variable;

  })();

}).call(this);
