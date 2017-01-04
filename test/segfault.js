#!/usr/bin/env node
process.title = 'custom-node'

console.log('running',process.title);

setTimeout(function() {
  console.error("going to crash",process.title);
  process.kill(process.pid, 'SIGSEGV');
}, 1000);
