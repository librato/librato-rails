module Librato
  module Rails
    class VersionSpecifier
      def self.supported(opts={}, &block)
        new(::Rails).supported(opts, &block)
      end

      def initialize(env)
        @env = env
      end

      def supported(opts={}, &block)
        unless block_given?
          raise VersionSpecifierError, 'version specific block required'
        end

        if !opts.key?(:min) && !opts.key?(:max)
          raise VersionSpecifierError, ':min and/or :max arguments required'
        end

        yield if is_supported?(opts)
      end

      private

      def version
        [@env::VERSION::MAJOR, @env::VERSION::MINOR].compact.join('.')
      end

      def is_supported?(opts={})
        if version >= opts[:min].to_s && !opts.key?(:max)
          return true
        elsif version <= opts[:max].to_s && !opts.key?(:min)
          return true
        elsif version.between?(opts[:min].to_s, opts[:max].to_s)
          return true
        else
          return false
        end
      end
    end

    class VersionSpecifierError < StandardError; end
  end
end
