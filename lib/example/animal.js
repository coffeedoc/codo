(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Example.Animal = (function() {

    function Animal(name, birthDate) {
      this.name = name;
      this.birthDate = birthDate != null ? birthDate : new Date();
      this.copulate = __bind(this.copulate, this);
    }

    Animal.prototype.move = function(options) {
      if (options == null) options = {};
    };

    Animal.prototype.copulate = function(animal) {};

    Animal.enterArk = function() {};

    return Animal;

  })();

}).call(this);
