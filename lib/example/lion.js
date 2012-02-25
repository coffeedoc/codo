(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Example.Animal.Lion = (function(_super) {

    __extends(Lion, _super);

    function Lion() {
      Lion.__super__.constructor.apply(this, arguments);
    }

    Lion.prototype.move = function(direction, speed) {
      return Lion.__super__.move.call(this, {
        direction: direction,
        speed: speed
      });
    };

    return Lion;

  })(Example.Animal);

}).call(this);
