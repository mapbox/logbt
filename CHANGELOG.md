# logbt changelog

# v3.0.0
 - On linux, now passing `print thread-events off` to gbd to avoid seeing noisy thread events
 - Removed `--keep-core`. Now we have a dedicated `--read-only-mode` (default false, needs to write to ensure core file directory is created) that will keep cores and well as not need write permissions in general (since it does not attempt to validate that the core file directory exists - you'll need it there already)
 - Added `--strict-mode` option (default false if not passed). If true then logbt will error if an unexpected core file is found during startup or if an unexpected core pattern is encountered. Without this option it will not error and will continue and do its best to function without these safeguards

# v2.0.3

 - Stopping logging when no corefile is found, which reduced verbosity of logs (#32)
 - Various readme and unit test updates.

# v2.0.2

 - Fixed the `logbt --test` command to work on OS X

# v2.0.1

 - Now attempts to display coredumps for all exit codes. This is important for detecting coredumps
   when there are multiple levels of indirection and commands do not correctly return the exit code
   of children that crashed.

# v2.0.0

 - Added [UPGRADING.md](UPGRADING.md) doc
 - Now you must first run `logbt --setup` with root privileges to setup the core_pattern
   - The `--setup` command sets a core_pattern of `/tmp/logbt-coredump/core.%p`
 - Now `logbt` does not need to run as root after `logbt --setup`
   - When run as non-root, the core_pattern of `/tmp/logbt-coredump/core.%p` is expected
 - Added `logbt --test` command to ensure backtraces are working
 - Refactored internal code to avoid mutable global variables

# v1.6.0

 - Fixed handling of non-tracked cores on linux (from crashing "grandchildren")

# v1.5.0

 - Fixed edge case in parsing corefile path on linux (when an extra `.` occurred in path to the binary)

# v1.4.0

 - Fixed support for lauching bash scripts with `logbt`. Previously only native programs were supported

# v1.3.0

 - Now displays backtraces for all likely descendant processes. This means that
   a backtrace will be displayed for "grandchildren" children of the
   program that `logbt` launches as well as the direct child.
 - Now warns at startup if existing corefiles are detected

# v1.2.0

 - Add support for when multiple programs crash by tracking pid of the child program
 - Added unit tests
 - Added sudo/sudoless support
 - Added support for both linux and osx

# v1.1.0

 - Now will print backtrace for any crash that generates a corefile (not just SIGSEGV)
 - Sets a core_pattern of `/tmp/logbt-coredump/core.%p` at startup

# v1.0.0

 - First release.
 - Sets a core_pattern of `/tmp/logbt-coredump` at startup
 - Must be run as root/sudo
 - Only prints backtrace when exit code of program is `139` (aka SIGSEGV/segfaults).
    - Will not work for aborts (SIGABRT), illegal instructions (SIGILL), floating point errors (SIGFPE), bus errors (SIGBUS), or other causes of C/C++ crashes.
 - Only prints backtrace for one corefile. If multiple processes crash behavior is undefined.
