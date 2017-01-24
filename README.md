librato-rails
=======

[![Gem Version](https://badge.fury.io/rb/librato-rails.png)](http://badge.fury.io/rb/librato-rails) [![Build Status](https://secure.travis-ci.org/librato/librato-rails.png?branch=master)](http://travis-ci.org/librato/librato-rails) [![Code Climate](https://codeclimate.com/github/librato/librato-rails.png)](https://codeclimate.com/github/librato/librato-rails)

`librato-rails` will report key statistics for your Rails app to [Librato](https://metrics.librato.com/) and allow you to easily track your own custom metrics. Metrics are delivered asynchronously behind the scenes so they won't affect performance of your requests.

Rails versions 3.0 or greater are supported on Ruby 1.9.3 and above.

Verified combinations of Ruby/Rails are available in our [build matrix](http://travis-ci.org/librato/librato-rails).

## Quick Start

> Note: If you have not yet enabled Rails on the [Librato integrations page](https://metrics.librato.com/integrations) within your account, do this first. This will automatically set up Rails and Rack Spaces, displaying many useful performance metrics.

Installing `librato-rails` and relaunching your application will automatically start the reporting of built-in performance metrics to your Librato account.

Once installed, custom metrics can also be added easily:

```ruby
# keep counts of key events
Librato.increment 'user.signup'

# easily benchmark sections of code to verify production performance
Librato.timing 'my.complicated.work' do
  # do work
end

# track averages across requests
Librato.measure 'user.social_graph.nodes', user.social_graph.size
```

## Installation

In your `Gemfile` add:

    gem 'librato-rails'

Then run `bundle install`.

## Configuration

If you don't have a Librato account already, [sign up](https://metrics.librato.com/). In order to send measurements to Librato you need to provide your account credentials to `librato-rails`. You can provide these one of two ways:

##### Use a config file

Create a `config/librato.yml` like the following:

```yaml
production:
  user: <your-email>
  token: <your-api-key>
```

The `librato.yml` file is parsed via ERB in case you need to add some host or environment-specific magic.

Note that using a configuration file allows you to specify different configurations per-environment. Submission will be disabled in any environment without credentials.

##### Use environment variables

Alternately you can provide `LIBRATO_USER` and `LIBRATO_TOKEN` environment variables. Unlike config file settings, environment variables will be used in all non-test environments (development, production, etc).

Note that if a config file is present, _all environment variables will be ignored_.

To see all config options or for information on combining config files and environment variables see the [full configuration docs](https://github.com/librato/librato-rails/wiki/Configuration).

##### Running on Heroku

If you are using the Librato Heroku addon, your user and token environment variables will already be set in your Heroku environment. If you are running without the addon you will need to provide them yourself.

If Heroku idles your application, measurements will not be sent until it receives another request and is restarted. If you see intermittent gaps in your measurements during periods of low traffic, this is the most likely cause.

If you are using Librato as a Heroku addon, [a paid plan](https://elements.heroku.com/addons/librato#pricing) is required for reporting custom metrics with librato-rails. You can view more about available addon levels [here](https://elements.heroku.com/addons/librato#pricing).

## Top-level Tags

**Tagged measurements are only available in the Tags Beta. Please [contact Librato support](mailto:support@librato.com) to join the beta.**

Librato Metrics supports tagged measurements that are associated with a metric, one or more tag pairs, and a point in time. For more information on tagged measurements, visit our [API documentation](https://www.librato.com/docs/api/#measurements-beta).

##### Default Tags

By default, `service`, `environment` and `host` are detected and applied as top-level tags for submitted measurements. Optionally, you can override the detected values in your configuration file:

```yaml
production:
  user: <your-email>
  token: <your-api-key>
  tags:
    service: 'myapp'
    environment: 'prod'
    host: 'myapp-prod-1'
```

##### Custom Tags

In addition to the default tags, you can also provide custom tags:

```yaml
production:
  user: <your-email>
  token: <your-api-key>
  tags:
    region: 'us-east-1'
```

Full information on configuration options is available on the [configuration wiki page](https://github.com/librato/librato-rails/wiki/Configuration).

## Automatic Measurements

After installing `librato-rails` and restarting your app you will see a number of new metrics appear in your Librato account. These track request performance, sql queries, mail handling, and other key stats.

Built-in performance metrics will start with either `rails` or `rack`, depending on the level they are being sampled from. For example: `rails.request.total` is the total number of requests rails has received each minute.

The metrics automatically recorded by `librato-rails` are organized into named metric suites that can be selectively enabled/disabled:

#### Rails Suites

###### Request Metrics

* *rails_controller*: Metrics which provide a high level overview of request performance including `rails.request.total`, `rails.request.time`, `rails.request.time.db`, `rails.request.time.view`, and `rails.request.slow`
* *rails_method*: `rails.request.method` metric with `method` tag name and HTTP method tag value, e.g. `method=POST`
* *rails_status*: `rails.request.status` metric with `status` tag name and HTTP status code tag value, e.g. `status=200`

###### System-Specific Metrics

* *rails_cache*: `rails.cache.*` metrics including reads, writes, hits & deletes
* *rails_job*: `rails.job.*` metrics including jobs queued, started & performed (Rails 4.2+)
* *rails_mail*: `rails.mail.*` metrics including mail sent / received
* *rails_render*: `rails.view.*` metrics including time to render individual templates & partials
* *rails_sql*: `rails.sql.*` metrics, including SELECT / INSERT / UPDATE / DELETEs as well as total query operations

#### Rack Suites

Rack measurements are taken from the very beginning of your [rack middleware stack](http://guides.rubyonrails.org/rails_on_rack.html). They include all time spent in your ruby process (not just in Rails proper). They will also show requests that are handled entirely in middleware and don't appear in the `rails` suites above.

* *rack*: The `rack.request.total`, `rack.request.time`, `rack.request.slow`, and `rack.request.queue.time` metrics
* *rack_method*: `rack.request.method` metric with `method` tag name and HTTP method tag value, e.g. `method=POST`
* *rack_status*: `rack.request.status` metric with `status` tag name and HTTP status code tag value, e.g. `status=200`

###### Queue Time

The `rack.request.queue.time` metric will show you queuing time (the time between your load balancer receiving a request & your application process starting to work on it) if your load balancer sets `HTTP_X_REQUEST_START` or `HTTP_X_QUEUE_START`.

#### Default Suites

All of the rails & rack suites listed above are enabled by default.

#### Suite Configuration

Suites can be configured via either the `LIBRATO_SUITES` environment variable or the `suites` setting in a `config/librato.yml` configuration file. The syntax is the same regardless of configuration method.

```bash
  LIBRATO_SUITES="rails_controller,rails_sql"  # use ONLY the rails_controller & rails_sql suites
  LIBRATO_SUITES="+foo,+bar"                   # + prefix: default suites plus foo & bar
  LIBRATO_SUITES="-rails_render"               # - prefix: default suites removing rails_render
  LIBRATO_SUITES="+foo,-rack_status"           # Default suites except for rack_status, also add foo
  LIBRATO_SUITES="all"                         # Enable all suites
  LIBRATO_SUITES="none"                        # Disable all suites
  LIBRATO_SUITES=""                            # Use only the default suites (same as if env var is absent)
```

Note that you should specify **either** an explicit list of suites to enable **or** add/subtract individual suites from the default list (using the +/- prefixes). If you try to mix these two forms a `Librato::Rack::InvalidSuiteConfiguration` error will be raised.

Configuring the metric suites via the `config/librato.yml` file would look like this:

```yaml
production:
  user: name@example.com
  token: abc123
  suites: 'rails_controller,rails_status,rails_sql,rack'
```

## Custom Measurements

Tracking anything that interests you is easy with Librato. There are four primary helpers available to use anywhere in your application:

#### increment

Use for tracking a running total of something _across_ requests, examples:

```ruby
# increment the 'sales_completed' metric by one
Librato.increment 'sales_completed'

# increment by five
Librato.increment 'items_purchased', by: 5

# increment with custom per-measurement tags
Librato.increment 'user.purchases', tags: { user: user.id, currency: 'USD', amount: '20' }
```

Other things you might track this way: user signups, requests of a certain type or to a certain route, total jobs queued or processed, emails sent or received

###### Sporadic Increment Reporting

Note that `increment` is primarily used for tracking the rate of occurrence of some event. Given this increment metrics are _continuous by default_: after being called on a metric once they will report on every interval, reporting zeros for any interval when increment was not called on the metric.

Especially with custom sources you may want the opposite behavior - reporting a measurement only during intervals where `increment` was called on the metric:

```ruby
# report a value for 'user.uploaded_file' only during non-zero intervals
Librato.increment 'user.uploaded_file', tags: { user: user.id, file_size: '390MB' }, sporadic: true
```

#### measure

Use when you want to track an average value _per_-request. Examples:

```ruby
Librato.measure 'user.social_graph.nodes', 212

# report from custom per-measurement tags
Librato.measure 'jobs.queued', 3, tags: { priority: 'high', worker: 'worker.12' }
```

#### timing

Like `Librato.measure` this is per-request, but specialized for timing information:

```ruby
Librato.timing 'twitter.lookup.time', 21.2

# report from custom per-measurement tags
Librato.measure 'api.response.time', time, tags: { node: node_name, db: 'rr1' }
```

The block form auto-submits the time it took for its contents to execute as the measurement value:

```ruby
Librato.timing 'twitter.lookup.time' do
  @twitter = Twitter.lookup(user)
end
```

###### Percentiles

By defaults timings will send the average, sum, max and min for every minute. If you want to send percentiles as well you can specify them inline while instrumenting:

```ruby
# track a single percentile
Librato.timing 'api.request.time', time, percentile: 95

# track multiple percentiles
Librato.timing 'api.request.time', time, percentile: [95, 99]
```

You can also use percentiles with the block form of timings:

```ruby
Librato.timing 'my.important.event', percentile: 95 do
  # do work
end
```

#### group

There is also a grouping helper, to make managing nested metrics easier. So this:

```ruby
Librato.measure 'memcached.gets', 20
Librato.measure 'memcached.sets', 2
Librato.measure 'memcached.hits', 18
```

Can also be written as:

```ruby
Librato.group 'memcached' do |g|
  g.measure 'gets', 20
  g.measure 'sets', 2
  g.measure 'hits', 18
end
```

Symbols can be used interchangably with strings for metric names.

## Use with ActiveSupport::Notifications

`librato-rails` and [ActiveSupport::Notifications](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) work great together. In fact, many of the Rails metrics provided are produced by subscribing to the [instrumentation events](http://edgeguides.rubyonrails.org/active_support_instrumentation.html) built into Rails.

Assume you have a custom event:

```ruby
ActiveSupport::Notifications.instrument 'my.event', user: user do
  # do work..
end
```

Writing a subscriber to capture that event and its outcomes is easy:

```ruby
ActiveSupport::Notifications.subscribe 'my.event' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  user = event.payload[:user]

  # track every time the event happens
  Librato.increment 'my.event'

  # track how long the event is taking
  Librato.timing 'my.event.time', event.duration

  # use payload data to do user-specific tracking
  Librato.increment 'user.did.event', tags: { user: user.id }, sporadic: true

  # do conditional tracking
  if user.feature_on?(:sample_group)
    Librato.increment 'user.sample.event'
  end

  # track slow events
  if event.duration >= 50.0
    Librato.increment 'my.event.slow'
  end
end
```

These are just a few examples. Combining `ActiveSupport::Notifications` instrumentation with Librato can be extremely powerful. As an added benefit, using the instrument/subscribers model allows you to isolate complex instrumentation code from your main application codebase.

## Custom Prefixes

You can set an optional prefix to all metrics reported by `librato-rails` in your [configuration](https://github.com/librato/librato-rails/wiki/Configuration). This can be helpful for isolating test data or forcing different apps to use different metric names.

## Tracking Deploys

It can be very useful to track your deploys using [annotations](http://dev.librato.com/v1/annotations) so you can use them to monitor the impact of changes to your app. Take a look at the [librato-rake-deploytrack gem](https://github.com/Jimdo/librato-rake-deploytrack) for an easy install option or [this ticket](https://github.com/librato/librato-rails/issues/41#issuecomment-50595104) for examples of how you can write your own.

## Use with Background Workers / Cron Jobs

`librato-rails` is designed to run within a long-running process and report periodically. Intermittently running rake tasks and most background job tools (delayed job, resque, queue_classic) don't run long enough for this to work.

Never fear, [we have some guidelines](https://github.com/librato/librato-rails/wiki/Monitoring-Background-Workers) for how to instrument your workers properly.


## Cross-Process Aggregation

`librato-rails` submits measurements back to the Librato platform on a _per-process_ basis. By default these measurements are then combined into a single measurement per top-level tags (default is `service`, `environment`, `host`) before persisting the data.

For example if you have 4 hosts with 8 unicorn instances each (i.e. 32 processes total), on the Librato site you'll find 4 data streams (1 per host) instead of 32.
Current pricing applies after aggregation, so in this case you will be charged for 4 streams instead of 32.

## Troubleshooting

Note that it may take 2-3 minutes for the first results to show up in your Librato account after you have started your servers with `librato-rails` enabled and the first request has been received.

#### Verbose Logging

If you want to get more information about `librato-rails` submissions to the Librato service you can set your `log_level` to `debug` (see [configuration](https://github.com/librato/librato-rails/wiki/Configuration)) to get detailed information added to your logs about the settings `librato-rails` is seeing at startup and when it is submitting.

Be sure to tail your logs manually (`tail -F <logfile>`) as the log output you get when using the `rails server` command often skips startup log lines.

If you are having an issue with a specific metric, using a `log_level` of `trace` will add the exact measurements being sent to your logs along with lots of other information about `librato-rails` as it executes. Neither of these modes are recommended long-term in production as they will add quite a bit of volume to your log file and will slow operation somewhat. Note that submission I/O is non-blocking, submission times are total time - your process will continue to handle requests during submissions.

#### Console Mode

By default the `librato-rails` reporter will not start in console mode, even if `librato-rails` is configured. If you want to force the reporter to run in console mode, set `LIBRATO_AUTORUN` to `1` in your environment:

```sh
$ LIBRATO_AUTORUN=1 rails console
```

#### Custom Flush Interval

If you are debugging setting up `librato-rails` locally you can set `flush_interval` to something shorter (say 10s) to force submission more frequently. Don't change your `flush_interval` in production as it will not result in measurements showing up more quickly, but may affect performance.

## Contribution

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project and submit a pull request from a feature or bugfix branch.
* Please include tests. This is important so we don't break your changes unintentionally in a future version.
* Please don't modify the gemspec, Rakefile, version, or changelog. If you do change these files, please isolate a separate commit so we can cherry-pick around it.

## Copyright

Copyright (c) 2012-2016 [Librato Inc.](http://librato.com) See LICENSE for details.
