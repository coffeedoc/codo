(function() {

  Example.Concerns.ConcernA = {
    ClassMethods: {
      a: function(a, b, c) {}
    },
    InstanceMethods: {
      hi: function(to) {}
    }
  };

  Example.Concerns.ConcernB = {
    ClassMethods: {
      z: function(x, y, z) {}
    },
    InstanceMethods: {
      goodbye: function(to) {}
    }
  };

  Example.Concern = (function() {

    function Concern() {}

    return Concern;

  })();

}).call(this);
