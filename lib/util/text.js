(function() {

  module.exports = {
    whitespace: function(n) {
      var a;
      n = n * 2;
      a = [];
      while (a.length < n) {
        a.push(' ');
      }
      return a.join('');
    }
  };

}).call(this);
