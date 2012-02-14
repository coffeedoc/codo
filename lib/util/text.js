(function() {

  module.exports = {
    whitespace: function(n) {
      var a;
      a = [];
      while (a.length < n) {
        a.push(' ');
      }
      return a.join('');
    }
  };

}).call(this);
