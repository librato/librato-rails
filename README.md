librato-rails
=======

[![Build Status](https://secure.travis-ci.org/librato/librato-rails.png?branch=master)](http://travis-ci.org/librato/librato-rails)

Report key statistics for your Rails app to [Librato Metrics](https://metrics.librato.com/), easily track your own custom metrics. Currently supports Rails 3.0+.

**NOTE: This is currently in alpha development and is not yet officially supported**

**NOTES FOR ALPHA TESTERS:**
 * If you are upgrading from a version prior to the rename to librato-rails, note that *the env variable names for configuration and the name of the config files have changed*. See the new names in configuration, below.
 * Starting with 0.4.0 *all metrics are now submitted as gauges*. If you were using a prior version you will need to manually remove any librato-rails generated metrics which are counters.

## Installation

In your `Gemfile` add:

    gem 'librato-rails'
    
Then run `bundle install`.

## Configuration

If you don't have a Metrics account already, [sign up](https://metrics.librato.com/). In order to send measurements to Metrics you need to provide your account credentials to `librato-rails`. You can provide these one of two ways:

Create a `config/librato.yml` like the following:

    production:
      user: <your-email>
      token: <your-api-key>

(the file is parsed via ERB in case you need to add some magic in there - useful in some cloud environments)

OR provide `LIBRATO_METRICS_USER` and `LIBRATO_METRICS_TOKEN` environment variables. If both env variables and a config file are present, environment variables will take precendence.

Note that using a configuration file allows you to specify configurations per-environment. Submission will be disabled in any environment without credentials. However, if environment variables are set they will be used in all environments. 

Full information on configuration options is available on the [configuration wiki page](https://github.com/librato/librato-rails/wiki/Configuration).

## Automatic Measurements

After installing `librato-rails` and restarting your app and you will see a number of new metrics appear in your Metrics account. These track request performance, sql queries, mail handling, and other key stats. All built-in performance metrics start with the prefix `rails` by convention &mdash; for example: `rails.request.total` is the total number of requests received during an interval. 

If you have multiple apps reporting to the same Metrics account you can change this prefix in your [configuration](https://github.com/librato/librato-rails/wiki/Configuration).

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

## Cross-process Aggregation

`librato-rails` submits measurements back to the Librato platform on a _per-process_ basis. By default these measurements are then combined into a single measurement per source (default is your hostname) before persisting the data. 

For example if you have 4 hosts with 8 unicorn instances each (i.e. 32 processes total), on the Metrics site you'll find 4 data streams (1 per host) instead of 32.
Current pricing applies after aggregation, so in this case you will be charged for 4 streams instead of 32.

If you want to report per-process instead, you can set `source_pids` to `true` in
your config, which will append the process id to the source name used by each thread. 

## Contribution

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project and submit a pull request from a feature or bugfix branch.
* Please include tests. This is important so we don't break your changes unintentionally in a future version.
* Please don't modify the gemspec, Rakefile, version, or changelog. If you do change these files, please isolate a separate commit so we can cherry-pick around it.

## Copyright

Copyright (c) 2012 [Librato Inc.](http://librato.com) See LICENSE for details.
