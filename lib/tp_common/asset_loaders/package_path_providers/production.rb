module TpCommon
  module AssetLoaders
    module PackagePathProviders
      class Production
        def initialize(default_cdn, _dev_cdn = nil)
          @default_cdn = default_cdn
          @dev_cdn = _dev_cdn

          @cache = Hash.new do |current_hash, key|
            current_hash[key] = key.to_s.split('.').insert(-2, 'min').join('.')
          end
        end

        def asset_url(package_name, version, asset)
          @cache[key(package_name, version, asset)]
        end

        private

        def key(package_name, version, asset)
          "#{@default_cdn}/spa/#{package_name}/#{version}/#{asset}".to_sym
        end
      end
    end
  end
end
