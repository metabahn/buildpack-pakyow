require "pathname"

module Pakyow
  module Buildpack
    class Config
      BLACKLIST = %w(PATH GEM_PATH GEM_HOME GIT_DIR JRUBY_OPTS JAVA_OPTS JAVA_TOOL_OPTIONS).freeze

      attr_reader :build_path, :cache_path, :vendor_path

      def initialize(build_path, cache_path, env_path)
        @build_path = Pathname.new(build_path)
        @cache_path = Pathname.new(cache_path)
        @vendor_path = @build_path.join("vendor")
        @env = load_env(env_path)
      end

      private def load_env(path)
        path = Pathname.new(path.to_s)

        if path.exist? && path.directory?
          path.each_child.each_with_object({}) { |file, env|
            key = file.basename.to_s

            unless blacklisted?(key)
              env[key] = file.read.strip
            end
          }
        else
          {}
        end
      end

      private def blacklisted?(key)
        BLACKLIST.include?(key.to_s)
      end
    end
  end
end
