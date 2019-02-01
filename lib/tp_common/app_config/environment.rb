require 'psych'
require 'yaml'

module TpCommon
  module AppConfig
    module Environment
      class << self
        # 2 levels of configuration:
        #
        # config/app_config.yml
        # ```
        #   app:
        #     name:
        #       detail:
        #   db:
        #     readonly: true
        # ```
        #
        # Environment variables. Variable name will be downcase and replace `__` by `.`
        # ```
        #   APP__NAME__DETAIL=octopus
        #   APP__NAME2=octopus2
        # ```
        # Value in environment variable will overwrite value in `config/app_config.yml`
        # BUT key will be ignore if doesn't exists in `config/app_config.yml`
        # So in case above,
        # ```
        #   TpCommon::AppConfig::Environment.fetch(:'app.name.detail') # => "octopus"
        #   TpCommon::AppConfig::Environment.fetch(:'app.name2') # => nil
        # ```
        # We could mixed both to use, but we recommend:
        #   use `config/app_config.yml` which committed to repo to know
        #     how many, what are config we use in app
        #     with default value (optional)
        #   use environment variables for differences config between stages (producion, staging, pre-production, ...)
        #
        def fetch(key)
          @app_config ||= load_config
          @app_config[key]
        end

        private

        def load_config
          default_config = Hash[*flatten_hash(load_yaml_config)].inject({}) do |carry, (key, value)|
            carry[key.to_sym] = value
            carry
          end

          ENV.each do |env_name, value|
            key = env_name.downcase.gsub('__', '.').to_sym

            if default_config.key?(key)
              default_config[key] = value
            end
          end

          default_config.freeze
        end

        def load_yaml_config
          file_path = if defined?(Rails)
            File.join(Rails.root,'config/app_config.yml')
          else
            File.join(File.dirname(__FILE__),'app_config.yml')
          end

          yaml = Pathname.new(file_path)
          if yaml.exist?
            require 'erb'
            (YAML.safe_load(ERB.new(yaml.read).result) || {}) || {}
          else
            raise "Could not load configuration. No such file - #{yaml}"
          end
        rescue Psych::SyntaxError => exception
          raise "YAML syntax error occurred while parsing #{yaml}. ",
                  'Please note that YAML must be consistently indented using spaces. Tabs are not allowed. ',
                  "Error: #{exception.message}"
        end

        def flatten_hash(my_hash, parent = [])
          my_hash.flat_map do |key, value|
            case value
            when Hash then
              flatten_hash(value, parent + [key])
            else
              [(parent + [key]).join('.'), value]
            end
          end
        end
      end
    end
  end
end
