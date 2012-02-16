(function() {

  Example.Animal = (function() {

    function Animal(name, birthDate) {
      this.name = name;
      this.birthDate = birthDate != null ? birthDate : new Date();
    }

    Animal.prototype.move = function(options) {
      if (options == null) options = {};
    };

    Animal.prototype.copulate = function(animal) {};

    return Animal;

  })();

}).call(this);
