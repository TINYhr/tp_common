module TpCommon
  module AssetLoaders
    module PackagePathProviders
      class Production
        def initialize(default_cdn)
          @default_cdn = default_cdn
        end

        def asset_url(package_name, version, asset)
          "#{cdn(package_name, version)}/#{asset.to_s.split('.').insert(-2, 'min').join('.')}"
        end
      end
    end
  end
end
