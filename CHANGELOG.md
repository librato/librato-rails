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
