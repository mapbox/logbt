var constants = require('constants');

if (!process.argv[2]) {
    console.error('Please pass integer interval to wait for (in seconds)');
    process.exit(1);
}

console.log('Process id is',process.pid);

Object.keys(constants).forEach(function(c) {
    if (c.indexOf('SIG') == 0 &&
        c !== 'SIGKILL' &&
        c !== 'SIGSTOP') {
        // attach handlers for all signals
        process.on(c,function() {
            console.log("node received",c);
            process.exit(constants[c]+128);
        })
    }
});

var interval = process.argv[2]*100;

console.log('Running for',process.argv[2],'s');

process.on('exit',function(code) {
    console.log('Exiting with',code);
});

var count = 0;

setInterval(function() {
    console.log('Running tic #',count++);
}, 200);

setTimeout(function() {
    console.log("Done after " + count + " tics, forcing exit");
    process.exit();
}, interval);


