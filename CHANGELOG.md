
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