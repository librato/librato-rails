metrics-rails
=======

[![Build Status](https://secure.travis-ci.org/librato/metrics-rails.png?branch=master)](http://travis-ci.org/librato/metrics-rails)

Report key statistics for your Rails app to [Librato Metrics](https://metrics.librato.com/), easily track your own custom metrics. Currently supports Rails 3+.

**NOTE: This is currently in alpha development and is not yet officially supported by the Librato team**

## Installation

In your `Gemfile` add:

    gem 'metrics-rails'
    
Then run `bundle install`.

## Configuration

If you don't have a Metrics account already, [sign up](https://metrics.librato.com/). In order to send measurements to Metrics you need to provide your account credentials to `metrics-rails`. You can provide these one of two ways:

Create a `config/metrics.yml` like the following:

    production:
      email: <your-email>
      api_key: <your-api-key>
      
OR provide `METRICS_EMAIL` and `METRICS_API_KEY` environment variables. If both env variables and a config file are present, environment variables will take precendence.

Note that using a configuration file allows you to specify configurations per-environment. Submission will be disabled in any environment without credentials. However, if environment variables are set they will be used in all environments. 

Full information on configuration options is available on the [configuration wiki page](https://github.com/librato/metrics-rails/wiki/Configuration).

## Automatic Measurements

After installing `metrics-rails` and restarting your app and you will see a number of new metrics appear in your Metrics account. These track request performance, sql queries, mail handling, and other key stats. All built-in performance metrics start with the prefix `rails` by convention &mdash; for example: `rails.request.total` is the total number of requests received during an interval. 

If you have multiple apps reporting to the same Metrics account you can change this prefix in your [configuration](https://github.com/librato/metrics-rails/wiki/Configuration).

## Custom Measurements

Tracking anything that interests you is easy with Metrics. Inside any controller or model there are three primary helpers available:

#### metrics_increment

Use for tracking a running total of something _across_ requests, examples:

    # increment the 'sales_completed' metric by one
    metrics.increment 'sales_completed'
    
    # increment by five
    metrics.increment 'items_purchased', 5
    
Other things you might track this way: user signups, requests of a certain type or to a certain route, total jobs queued or processed, emails sent or received

#### metrics_measure

Use when you want to track an average value _per_-request. Examples:

    metrics.measure 'user.social_graph.nodes', 212

    metrics.measure 'jobs.queued', 3
    

#### metrics_timing

Like `metrics.measure` this is per-request, but specialized for timing information:

    metrics.timing 'twitter.lookup.time', 21.2
	
The block form auto-submits the time it took for its contents to execute as the measurement value:

    metrics.timing 'twitter.lookup.time' do
      @twitter = Twitter.lookup(user)
    end

#### metrics_group

There is also a grouping helper, to make managing nested metrics easier. So this:

    metrics.measure 'memcached.gets', 20
    metrics.measure 'memcached.sets', 2
    metrics.measure 'memcached.hits', 18
    
Can also be written as:

    metrics.group 'memcached' do |g|
      g.measure 'gets', 20
      g.measure 'sets', 2
      g.measure 'hits', 18
    end

Symbols can be used interchangably with strings for metrics names.

If you want to write custom metrics from outside of your models and controllers (or are using an ORM other than ActiveRecord)you can access the `Metrics::Rails` object directly and drop the `metrics.` from the beginning of the helper name. For example:

    Metrics::Rails.timing 'custom_cache.time', 8.2
    Metrics::Rails.increment 'user.signups'

## Contribution

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project and submit a pull request from a feature or bugfix branch.
* Please include tests. This is important so we don't break your changes unintentionally in a future version.
* Please don't modify the gemspec, Rakefile, version, or changelog. If you do change these files, please isolate a separate commit so we can cherry-pick around it.

## Copyright

Copyright (c) 2012 [Librato Inc.](http://librato.com) See LICENSE for details.
