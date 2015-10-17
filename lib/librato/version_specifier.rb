module VersionSpecifier
  def self.supported(opts={})
    unless block_given?
      raise LocalJumpError, 'version specific code block required'
    end

    if !opts.key?(:min) && !opts.key?(:max)
      raise ArgumentError, ':min and/or :max arguments required'
    end

    return yield if version >= opts[:min].to_s && !opts.key?(:max)
    return yield if version <= opts[:max].to_s && !opts.key?(:min)
    return yield if version.between?(opts[:min].to_s, opts[:max].to_s)
  end

  private

  def self.version
    [Rails::VERSION::MAJOR, Rails::VERSION::MINOR].compact.join('.')
  end
end
