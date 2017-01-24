var constants = require('constants');

if (!process.argv[2]) {
    console.error('Please pass integer interval to wait for (in seconds)');
    process.exit(1);
}

console.log('Process id is',process.pid);

process.on('SIGTERM',function() {
    console.log("node received",'SIGTERM');
    setTimeout(function() {
        process.exit(constants['SIGTERM']+128);
    }, 200);
})

var interval = process.argv[2]*1000;

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


