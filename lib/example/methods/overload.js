(function() {
  var __slice = [].slice;

  Example.Methods.Overload = (function() {

    function Overload() {}

    Overload.prototype.set = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    };

    return Overload;

  })();

}).call(this);
