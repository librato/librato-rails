# Frequently asked questions for librato-rails

#### What is the difference between rack.request.time and rails.request.time, etc?

The `rails.request.*` metrics are reported using rails' built-in instrumentation and show rails' [internal benchmarks](http://edgeguides.rubyonrails.org/active_support_instrumentation.html) for request execution.

The `rack.request.*` metrics are generated from within the rack middleware and are guaranteed to always be greater than or equal to rails' real execution time.

On versions of `librato-rails` prior to 0.9.0 these can appear similar as the middleware is loaded on the top of the stack but on 0.9.0 or greater the entire middleware stack is recorded. Recording the whole stack gives you a better sense of actual request processing time and also the ability to differentiate how many of your requests are being handled in middleware and what percentage of your request time is being taken up by middleware.

#### I've noticed that the HTTP request sending my metrics sometimes takes a while, isn't that slowing down my web server or limiting how many requests I can handle?

Submissions to the Metrics service take place in a background thread which runs extremely quickly and has minimal impact on your primary request-serving thread or threads.

The only time that the worker uses any CPU is to package up submissions, which is highly optimized. While the worker thread is sleeping or waiting for a response it is non-blocking and doesn't compete with your request-serving threads.

Even if you are using a single-threaded _app server_ like unicorn or thin, you are still running in a multi-threaded _environment_ (the ruby interpreter) so the worker thread will run and report successfully.