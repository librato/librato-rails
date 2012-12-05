librato-rails
=======

[![Build Status](https://secure.travis-ci.org/librato/librato-rails.png?branch=master)](http://travis-ci.org/librato/librato-rails)

`librato-rails` will report key statistics for your Rails app to [Librato Metrics](https://metrics.librato.com/) and allow you to easily track your own custom metrics. Metrics are delivered asynchronously behind the scenes so they won't affect performance of your requests.

Currently Rails 3.0+ and Ruby 1.9.2+ are required.

You may want to read the [notes on upgrading](https://github.com/librato/librato-rails/wiki/Alpha-Tester-Upgrade-Notes) if you were an alpha tester.

## Quick Start

Installing `librato-rails` and relaunching your application will automatically start the reporting of metrics to your Metrics account.

After installation `librato-rails` will detect your environment and start reporting available performance information for your application.

Custom metrics can also be added easily:

    # keep counts of key events
    Librato.increment 'user.signup'

    # easily benchmark sections of code to verify production performance
    Librato.timing 'my.complicated.work' do
      # do work
    end

    # track averages across requests
    Librato.measure 'user.social_graph.nodes', user.social_graph.size

## Installation

In your `Gemfile` add:

    gem 'librato-rails'

Then run `bundle install`.

## Configuration

If you don't have a Metrics account already, [sign up](https://metrics.librato.com/). In order to send measurements to Metrics you need to provide your account credentials to `librato-rails`. You can provide these one of two ways:

##### Use a config file

Create a `config/librato.yml` like the following:

    production:
      user: <your-email>
      token: <your-api-key>

The `librato.yml` file is parsed via ERB in case you need to add some host or environment-specific magic.

Note that using a configuration file allows you to specify different configurations per-environment. Submission will be disabled in any environment without credentials.

##### Use environment variables

Alternately you can provide `LIBRATO_USER` and `LIBRATO_TOKEN` environment variables. Unlike config file settings, environment variables will be used in all non-test environments (development, production, etc).

Note that if a config file is present, _all environment variables will be ignored_.

For more information on combining config files and environment variables, see the [full configuration docs](https://github.com/librato/librato-rails/wiki/Configuration).

##### Running on Heroku

If you are using the Librato Metrics Heroku addon, your user and token environment variables will already be set in your Heroku environment. If you are running without the addon you will need to provide them yourself.

In either case you will need to specify a custom source for your app to track properly. If `librato-rails` does not detect an explicit source it will not start. You can set the source in your environment:

    heroku config:add LIBRATO_SOURCE=myappname

If you are using a config file, add your source entry to that instead.

Full information on configuration options is available on the [configuration wiki page](https://github.com/librato/librato-rails/wiki/Configuration).

Note that if Heroku idles your application measurements will not be sent until it receives another request and is restarted. If you see intermittent gaps in your measurements during periods of low traffic this is the most likely cause.

## Automatic Measurements

After installing `librato-rails` and restarting your app and you will see a number of new metrics appear in your Metrics account. These track request performance, sql queries, mail handling, and other key stats.

Built-in performance metrics will start with either `rack` or `rails`, depending on the level they are being sampled from. For example: `rails.request.total` is the total number of requests rails has received each minute.

## Custom Measurements

Tracking anything that interests you is easy with Metrics. There are four primary helpers available:

#### increment

Use for tracking a running total of something _across_ requests, examples:

    # increment the 'sales_completed' metric by one
    Librato.increment 'sales_completed'

    # increment by five
    Librato.increment 'items_purchased', :by => 5

    # increment with a custom source
    Librato.increment 'user.purchases', :source => user.id

Other things you might track this way: user signups, requests of a certain type or to a certain route, total jobs queued or processed, emails sent or received

###### Sporadic Increment Reporting

Note that `increment` is primarily used for tracking the rate of occurrence of some event. Given this increment metrics are _continuous by default_: after being called on a metric once they will report on every interval, reporting zeros for any interval when increment was not called on the metric.

Especially with custom sources you may want the opposite behavior - reporting a measurement only during intervals where `increment` was called on the metric:

    # report a value for 'user.uploaded_file' only during non-zero intervals
    Librato.increment 'user.uploaded_file', :source => user.id, :sporadic => true

#### measure

Use when you want to track an average value _per_-request. Examples:

    Librato.measure 'user.social_graph.nodes', 212

	# report from a custom source
    Librato.measure 'jobs.queued', 3, :source => 'worker.12'


#### timing

Like `Librato.measure` this is per-request, but specialized for timing information:

    Librato.timing 'twitter.lookup.time', 21.2

The block form auto-submits the time it took for its contents to execute as the measurement value:

    Librato.timing 'twitter.lookup.time' do
      @twitter = Twitter.lookup(user)
    end

#### group

There is also a grouping helper, to make managing nested metrics easier. So this:

    Librato.measure 'memcached.gets', 20
    Librato.measure 'memcached.sets', 2
    Librato.measure 'memcached.hits', 18

Can also be written as:

    Librato.group 'memcached' do |g|
      g.measure 'gets', 20
      g.measure 'sets', 2
      g.measure 'hits', 18
    end

Symbols can be used interchangably with strings for metric names.

## Custom Prefix

You can set an optional prefix to all metrics reported by `librato-rails` in your [configuration](https://github.com/librato/librato-rails/wiki/Configuration). This can be helpful for isolating test data or forcing different apps to use different metric names.

## Cross-Process Aggregation

`librato-rails` submits measurements back to the Librato platform on a _per-process_ basis. By default these measurements are then combined into a single measurement per source (default is your hostname) before persisting the data.

For example if you have 4 hosts with 8 unicorn instances each (i.e. 32 processes total), on the Metrics site you'll find 4 data streams (1 per host) instead of 32.
Current pricing applies after aggregation, so in this case you will be charged for 4 streams instead of 32.

If you want to report per-process instead, you can set `source_pids` to `true` in
your config, which will append the process id to the source name used by each thread.

## Troubleshooting

Note that it may take 2-3 minutes for the first results to show up in your Metrics account after you have started your servers with `librato-rails` enabled and the first request has been received.

If you want to get more information about `librato-rails` submissions to the Metrics service you can set your `log_level` to `debug` (see [configuration](https://github.com/librato/librato-rails/wiki/Configuration)) to get detailed information added to your logs about the settings `librato-rails` is seeing at startup and when it is submitting.

If you are having an issue with a specific metric, using a `log_level` of `trace` will add the exact measurements being sent to your logs along with lots of other information about `librato-rails` as it executes. Neither of these modes are recommended long-term in production as they will add quite a bit of volume to your log file and will slow operation somewhat. Note that submission I/O is non-blocking, submission times are total time - your process will continue to handle requests during submissions.

If you are debugging setting up `librato-rails` locally you can set `flush_interval` to something shorter (say 10s) to force submission more frequently. Don't change your `flush_interval` in production as it will not result in measurements showing up more quickly, but may affect performance.

## Contribution

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project and submit a pull request from a feature or bugfix branch.
* Please include tests. This is important so we don't break your changes unintentionally in a future version.
* Please don't modify the gemspec, Rakefile, version, or changelog. If you do change these files, please isolate a separate commit so we can cherry-pick around it.

## Copyright

Copyright (c) 2012 [Librato Inc.](http://librato.com) See LICENSE for details.
