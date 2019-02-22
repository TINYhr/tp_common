module TpCommon
  module AssetLoaders
    module Errors
      class AssetNotFound < ::StandardError; end
      class PackageIsNotLoaded < ::StandardError; end
    end
  end
end
