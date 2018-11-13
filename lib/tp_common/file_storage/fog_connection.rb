require 'fog/aws'

module TpCommon
  module FileStorage
    # Provide default connection to file storage service
    #
    module FogConnection

      private

      def create_connection
        Fog::Storage.new(provider: 'AWS',
          aws_access_key_id: FileStorage.configuration.aws_key_id,
          aws_secret_access_key: FileStorage.configuration.aws_secret_key)
      end
    end
  end
end
