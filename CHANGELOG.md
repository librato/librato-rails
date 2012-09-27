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
