process.title = 'custom-node'

console.log('running',process.title);

setTimeout(() => {
  console.error("going to crash",process.title);
  process.kill(process.pid, 'SIGSEGV');
}, 1000);
