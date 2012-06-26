require 'metrics-rails/version'

module MetricsRails
  
  def client
    
  end
  
  def counters
    @counter_cache ||= CounterCache.new
  end
  
  class CounterCache
    extend Forwardable
    
    #def_delegators :@cache, :[]
    
    def initialize
      @cache = {}
    end
    
    def [](key)
      @cache[key.to_s]
    end
    
    def increment(counter, by=1)
      counter = counter.to_s
      @cache[counter] ||= 0
      @cache[counter] += by
    end
    
  end
  
end
