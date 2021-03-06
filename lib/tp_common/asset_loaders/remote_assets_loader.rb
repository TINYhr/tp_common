require 'tp_common/asset_loaders/errors'
require 'tp_common/asset_loaders/package_path_providers/production'
TpCommon::AssetLoaders::ProviderClass = if defined?(Rails) && (Rails.env.development? || Rails.env.test?)
  require 'tp_common/asset_loaders/package_path_providers/development'
  TpCommon::AssetLoaders::PackagePathProviders::Development
else
  TpCommon::AssetLoaders::PackagePathProviders::Production
end

module TpCommon
  module AssetLoaders
    # This class supports switching between development env and production env in loading assets
    # Follow TINYpulse development convention.
    # - Use minified assets on cdn for production
    # - On development, prefer development spa on local, if not, fallback to production behaviors
    #
    # To config:
    # ```
    # TpCommon::AssetLoaders::RemoteAssetsLoader.configure do |config|
    #   config.cdn = 'https://other.hotter.cdn'
    #   # And for development mode, add more
    #   config.dev_cdn = 'http://app.lvh.me:3001'
    # end
    # # Load a package. This is required.
    # TpCommon::AssetLoaders::RemoteAssetsLoader.load(:'any-spa', 'v1.0.0')
    # ```
    #
    # Use in template:
    # ```
    # <%= javascript_include_tag TpCommon::AssetLoaders::RemoteAssetsLoader[:'any-spa']['main.js'] %>
    # ```
    class RemoteAssetsLoader
      DEFAULT_CDN = 'https://cdn.tinypulse.com/spa'
      LoaderConfiguration = Struct.new(:cdn,
                                       :dev_cdn,
                                       :package_path_provider,
                                       :enable_hot_reload,
                                       :redis_connection)

      class << self
        # Configure RemoteAssetsLoader, for now, only :cdn is supported
        # ```
        #   TpCommon::AssetLoaders::RemoteAssetsLoader.configure do |config|
        #     config.cdn = 'https://other.hotter.cdn'
        #   end
        # ```
        def configure
          yield(config)

          config.enable_hot_reload = !!config.enable_hot_reload
          raise StandardError.new('Please add :redis_connection if enable hot_reload') if config.enable_hot_reload && config.redis_connection.nil?
          config.package_path_provider = TpCommon::AssetLoaders::ProviderClass.new(config.cdn, config.dev_cdn)
        end

        # Load a package (SPA) with specific version to use.
        # ```
        #   TpCommon::AssetLoaders::RemoteAssetsLoader.load(:'tinypulse-spa-1', 'v1.0.0')
        # ```
        #
        # To prioritize version from env variable, we dont provide this magic here
        # So declare it explicitly when load:
        # ```
        #   TpCommon::AssetLoaders::RemoteAssetsLoader.load(:'tinypulse-spa-1', ENV['SPA_VERSION_TINYPULSE_SPA_1_HOT_CHANGE'] || 'v1.0.0')
        # ```
        #
        # For multiple packages:
        # ```
        #   TpCommon::AssetLoaders::RemoteAssetsLoader.load(
        #     'tinypulse-spa-1': 'v1.0.0',
        #     'tinypulse-spa-2': 'v1.0.0',
        #     'tinypulse-spa-3': 'v1.0.0')
        # ```
        #
        def load(package_name, version = nil)
          if version
            package_name = package_name.to_sym
            packages[package_name] = new(package_name, version)
            packages
          else
            all_packages = Hash(package_name)
            all_packages.each do |key, ver|
              packages[key] = new(key, ver)
            end

            packages
          end
        end

        # TODO: [AV] Add desc before release
        def cache_set(package_name, version)
          config.redis_connection.set(cache_key(package_name), version)
        end

        # TODO: [AV] Add desc before release
        def cache_get(package_name)
          config.redis_connection.get(cache_key(package_name))
        end

        # TODO: [AV] Add desc before release
        def cache_unset(package_name)
          config.redis_connection.del(cache_key(package_name))
        end

        # Get package:
        # ```
        #   TpCommon::AssetLoaders::RemoteAssetsLoader[:'tinypulse-spa-1'][:'main.js'] # 'https://some.cdn/spa/tinypulse-spa-1/v1.0.0/main.js'
        # ```
        # Raise `PackageIsNotLoaded` exception if package is not found.
        #
        # - In Rails development environment, Asset loader will try to ping and access assets at localhost:3001
        #     Which assets are served without minified, so file name is keep the same.
        # - In other environments, assets are minified and served through cdn
        #     File name will be append `.min` before extension. i.e. 'main.min.js'
        #
        def [](package_name)
          packages[package_name].tap do |package|
            raise TpCommon::AssetLoaders::Errors::PackageIsNotLoaded.new("Package #{package_name} is not loaded yet.") if package.nil?
          end
        end

        def asset_url(package_name, version, asset)
          if config.enable_hot_reload
            cached_version = cache_get(package_name)
            if cached_version
              return config.package_path_provider.asset_url(package_name, cached_version, asset)
            end
          end

          config.package_path_provider.asset_url(package_name, version, asset)
        end

        private

        def cache_key(package_name)
          "tp_common/asset_loaders/remote_assets_loader/#{package_name}"
        end

        def new_config
          LoaderConfiguration.new(DEFAULT_CDN, nil)
        end

        def config
          @config ||= new_config
        end

        def packages
          @packages ||= {}
        end
      end

      def initialize(package_name, version)
        @package_name = package_name
        @version = version
      end

      def [](asset_name)
        # TODO: [AV] Do performance test and cache the string in system level
        # NOTE: [AV] It's secure to check this asset url exists by Net::HTTP then try more than 1 cdn.
        #       but DONT DO IT. Using unavailable spa version/cdn is a SERIOUS problem need to solve, not auto-recovery
        #       beside, this url will be called every page hit, so any milisecond are counted.
        RemoteAssetsLoader.asset_url(@package_name, @version, asset_name)
      end
    end
  end
end
