# v2.0.0

 - Added [UPGRADING.md](UPGRADING.md) doc
 - Now you must first run `logbt --setup` with root privileges to setup the core_pattern
 - Now `logbt` does not need to run as root after `logbt --setup`
 - Added `logbt --test` command to ensure backtraces are working
 - Refactored internal code to avoid mutable global variables

# v1.6.0

 - Fixed handling of non-tracked cores on linux

# v1.5.0

 - Fixed edge case in parsing corefile path on linux (when extra . in path to binary)

# v1.4.0

 - Fixed support for this situation: `logbt ./bash_script_that_calls_a_child_that_crashes.sh`. Previously
   this would result in broken backtraces because we did not know what native program crashed and instead
   incorrectly passed the non-native program name to gdb/lldb.

# v1.3.0

 - Now displays backtraces for all likely descendant processes. This means that
   a backtrace will be displayed if a process crashes that is a child of the
   program that `logbt` launches
 - Now warns at startup if existing corefiles are detected

# v1.2.0

 - Fixed display of backtraces by tracking pid of child program
 - Added tests
 - Added sudo/sudoless support
 - Added support for both linux and osx

# v1.1.0

 - Second release (not yet functional)

# v1.0.0

 - First release (not yet functional)