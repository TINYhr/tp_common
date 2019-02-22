require 'net/http'

module TpCommon
  module AssetLoaders
    module PackagePathProviders
      class Development < Production
        DEVELOPMENT_CDN = 'http://localhost:3001'

        def asset_url(package_name, version, asset)
          @development ||= head("#{DEVELOPMENT_CDN}/_ping")
          if @development
            return "#{cdn(package_name, version)}/#{asset}"
          end

          super(package_name, version, asset)
        end

        private

        def head(url_string)
          url = URI.parse(url_string)
          req = Net::HTTP.new(url.host, url.port)
          req.use_ssl = (url.scheme == 'https')

          path = url.path unless url.path.nil?

          res = begin
                  req.request_head(path || '/')
                rescue StandardError
                  nil
                end

          res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPRedirection)
        end
      end
    end
  end
end
