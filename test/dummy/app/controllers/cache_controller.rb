class CacheController < ApplicationController
  before_filter :instrument_caching
  after_filter  :clear_cache

  def read
    Rails.cache.write('myfoo', 'bar', expires_in: 60.seconds)
    Rails.cache.read('myfoo')
    render :nothing => true
  end

  def write
    Rails.cache.write('myfoo', 'bar', expires_in: 60.seconds)
    render :nothing => true
  end

  def fetch_hit
    Rails.cache.write('myfetch', 'bar', expires_in: 60.seconds)
    Rails.cache.fetch('myfetch', expires_in: 60.seconds) { "populate" }
    render :nothing => true
  end

  def generate
    Rails.cache.fetch('newdata', expires_in: 60.seconds) { "populate" }
    render :nothing => true
  end

  def delete
    Rails.cache.write('something', 'bar', expires_in: 60.seconds)
    Rails.cache.delete('something')
    render :nothing => true
  end

  private

  def clear_cache
    Rails.cache.clear
  end

  def instrument_caching
    # ensure caching instrumentation is turned on
    Rails.cache.class.instrument = true
  end

end
