(function() {
  "use strict";  module.exports = function(grunt) {
    return grunt.registerMultiTask("blitz", "Run blitz.io sprints and rushes here", function() {
      var options;

      options = this.options({
        punctuation: ".",
        separator: ", ",
        blitzid: grunt.option('blitzid'),
        blitzkey: grunt.option('blitzkey')
      });
      if (options.blitzid == null) {
        this.requiresConfig("blitzid");
      }
      if (options.blitzkey == null) {
        this.requiresConfig("blitzkey");
      }
      grunt.log.writeln("Using blitz id: " + options.blitzid);
      return grunt.log.writeln("Using blitz key: " + options.blitzkey);
    });
  };

}).call(this);
