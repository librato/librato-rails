class Librato::Rack::Middleware
  def initialize(app, metrics = Librato::Rails)
    @app, @metrics = app, metrics
  end

  def call(env)
    @metrics.check_worker if @metrics.send(:forking_server?)

    header_metrics env

    time     = Time.now
    response = @app.call(env)
    duration = (Time.now - time) * 1000.0

    request_metrics response.first, duration

    response
  end

  private

  def header_metrics(env)
    return unless env.keys.include?('HTTP_X_HEROKU_QUEUE_DEPTH')

    @metrics.group 'rack.heroku' do |group|
      group.measure 'queue.depth',     env['HTTP_X_HEROKU_QUEUE_DEPTH'].to_f
      group.timing  'queue.wait_time', env['HTTP_X_HEROKU_QUEUE_WAIT_TIME'].to_f
      group.measure 'queue.dynos',     env['HTTP_X_HEROKU_DYNOS_IN_USE'].to_f
    end
  end

  def request_metrics(status, duration)
    @metrics.group 'rack.request' do |group|
      group.increment 'total'
      group.timing    'time', duration
      group.increment 'slow' if duration > 200.0

      group.group 'status' do |s|
        s.increment status
        s.increment "#{status.to_s[0]}xx"

        s.timing "#{status}.time", duration
        s.timing "#{status.to_s[0]}xx.time", duration
      end
    end
  end
end
