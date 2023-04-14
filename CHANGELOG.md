### Version 2.1.0
* Add Rails 5.0 support (#135)

### Version 2.0.0
* Add support for tagged measurements (#123). **NOTE**: This version introduces breaking changes for legacy sources. Please contact support@librato.com to learn more.

### Version 1.4.2
* Remove calls to `File#exists?` as that method is removed in ruby 3.2

### Version 1.4.2
* Bump librato-rack dependency to fix warns with ruby 2.4

### Version 1.4.1
* Bump librato-rack dependency to fix missing p95 for rack.request.time
* Loosen librato-rack dependency to any 1.0.x versions

### Version 1.4.0
* Add support to instrument all controller actions, e.g., `instrument_action :all`.

### Version 1.3.0
* Add support for configurable metric suites

### Version 1.2.0
* Allow use of Rails.application.secrets in the librato.yaml (Zack Siri)

### Version 1.1.0
* Add HTTP proxy support

### Version 1.0.0
* Add Active Job support for job counters and timings
* Add `VersionSpecifier` to manage Rails version runtime dependencies

### Version 0.12.0
* Add percentile support for timings
* Start reporting 95th percentile for key ActionController metrics

### Version 0.11.1
* Use controller/action as source for instrument_action metrics

### Version 0.11.0
* Add instrument_action for profiling a specific controller action

### Version 0.10.3
* Relax rails loading requirements

### Version 0.10.2
* Ensure yaml is always loaded when needed (Daniel Marschner)

### Version 0.10.1
* Add ability to force reporter to start at startup via LIBRATO_AUTORUN

### Version 0.10.0
* Add render instrumentation metrics
* Add cache instrumentation metrics
* Add metrics on HTTP method use
* Rack middleware now racks itself first, improving value of rack metrics (Thibaud Guillaume-Gentil)
* Add ability to control startup with LIBRATO_AUTORUN
* Add ability to force startup in console mode with LIBRATO_AUTORUN
* Refactor to use librato-rack
* Remove old deprecated heroku-specific stats
* Fix startup bug when using unicorn with preload false
* Fix bug where grouped instrumentation could lose some options
* Sign gem when building
* Documentation improvements

### Version 0.9.0
* Bump librato-metrics dependency version for new functionality

### Version 0.8.2
* Allow override of logging location (Rick Martinez)

### Version 0.8.1
* Bump librato-metrics to fix issue with Rails 3.1.6

### Version 0.8.0
* Add support for terser `LIBRATO_` prefixed environment variables
* Deprecate `LIBRATO_METRICS_` prefixed environment variables
* Always check worker, not just in forking servers
* Refactor configuration/logging functionality into standalone modules

### Version 0.7.3
* More resilient handling of invalid metric/source names
* Don't start if provided source is invalid

### Version 0.7.2
* Relax multi_json version requirement to allow running with Rails 3.1/3.0
* Fix exception if current environment is not in config file
* Always respect LIBRATO_METRICS_LOG_LEVEL env variable for easier startup debugging
* Add more debugging statements in startup sequence

### Version 0.7.1
* Support for Passenger 4 (James Miller)

### Version 0.7.0
* Add configurable log_level for easier debugging
* Show settings during startup in debug mode
* Logs are now redirected to be visible when running on Heroku
* Fix running with unicorn on Heroku
* Don't start on Heroku without an explicit source being set
* Improve log messages
* Clean up tracing output for measurements
* Remove redundant per-measurement time tracking
* Add some initial benchmarks of instrumenting performance
* Added troubleshooting and heroku setup sections to README
* Documentation improvements

### Version 0.6.0
* Add support for custom sources per measurement via increment
* Add support for custom sources per measurement via measure/timing
* Add support for sporadic (non-continuous) increment metrics
* Aggregate metrics by source by default
* Don't append pids to sources by default anymore
* Start extracting collector behaviors into Collector
* measure/timing metrics prefix now updates dynamically if .prefix changes after startup
* Fix issue with some helpers not being found when running on unicorn
* Fix issue with sometimes attempting submission without full credentials
* Documentation improvements

### Version 0.5.2
* Fix bug where measure/timing events don't apply global prefix properly
* Fix bug where increment events could have missing values if not called

### Version 0.5.1
* Remove old helper libs which may cause load conflict for rails helpers
* Don't lock mutex during duration of timing blocks

### Version 0.5.0
* Support block form of timing
* Config option to disable pid inclusion in source (Chris Roby)
* Change prefix handling to be global for all reported metrics
* Fix misassignment of source to prefix

### Version 0.4.1
* Fix whitespace-before-params warning.

### Version 0.4.0
* Support ERB config file using env variables. (Justin Smestad)
* Precedence changed to favor YAML config (if present) over env vars.
  Mirrors Heroku add-on model. (Justin Smestad)
* Report counters as gauge increments instead.

### Version 0.3.1
* Fix config file fields to match new env variables

### Version 0.3.0
* Rename to librato-rails
* Change env variables to LIBRATO_METRICS_USER and LIBRATO_METRICS_TOKEN

### Version 0.2.0
* Add rack middleware component (Pat Allan)
* Fix config file detection (Rafael Chacon)
