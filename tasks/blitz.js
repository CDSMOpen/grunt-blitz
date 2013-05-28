(function() {
  "use strict";
  var Blitz;

  Blitz = require('blitz');

  module.exports = function(grunt) {
    return grunt.registerMultiTask("blitz", "Run blitz.io sprints and rushes from grunt", function() {
      var blitz, done, options, sprint;

      done = this.async();
      options = this.options({
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
      grunt.log.writeln("Using blitz key: " + options.blitzkey);
      blitz = new Blitz(options.blitzid, options.blitzkey);
      sprint = blitz.sprint({
        steps: [
          {
            url: options.url
          }
        ],
        region: 'ireland'
      });
      sprint.on("complete", function(data) {
        var step, _i, _len, _ref;

        console.log("Region: " + data.region);
        console.log("Duration: " + data.duration);
        _ref = data.steps;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          step = _ref[_i];
          console.log("Connect: " + step.connect);
          console.log("Duration: " + step.duration);
          console.dir(step);
        }
        return done();
      });
      return sprint.on("error", function(response) {
        console.log("error: " + response.error);
        console.log("reason: " + response.reason);
        return done();
      });
    });
  };

}).call(this);
