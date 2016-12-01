var child_process = require('child_process');
var constants = require('constants');
var path = require('path');

var script = path.join(__dirname,'segfault.js');
var child = child_process.spawn(process.execPath,[script]);

child.stdout.on('data', function(data) {
  process.stdout.write(data.toString());
});

child.stderr.on('data', function(data) {
  process.stderr.write(data.toString());
});

child.on('error', function(err) {
  process.stderr.write(err.message);
});

child.on('exit', function(code,signal) {
  if (code == 0) {
    process.exit(0);
  } else if (code != undefined) {
    process.exit(code)
  } else {
    var signal_code = constants[signal]+128;
    process.exit(signal_code);
  }
});