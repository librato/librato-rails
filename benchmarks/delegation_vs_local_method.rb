$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'benchmark/ips'

require 'forwardable'

class Receiver
  def doit
    "done did it"
  end
end

class SenderOne
  def doit
    receiver.doit
  end

  private

  def receiver
    @receiver ||= Receiver.new
  end
end

class SenderTwo
  extend Forwardable
  def_delegators :receiver, :doit

  private

  def receiver
    @receiver ||= Receiver.new
  end
end

sender_one = SenderOne.new
sender_two = SenderTwo.new

Benchmark.ips do |x|
  x.report('local method') do
    sender_one.doit
  end

  x.report('delegation') do
    sender_two.doit
  end
end
