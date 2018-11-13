require 'fog/aws'
require 'tp_common/file_storage/fog_connection'
require 'tp_common/file_storage/key_protector'

module TpCommon
  module FileStorage
    # Prepare connection, key protector, consts for working wilt s3 files
    class Base
      MAX_RETRIES = 3

      include TpCommon::FileStorage::FogConnection
      include TpCommon::FileStorage::KeyProtector

      def initialize(directory_path = nil)
        @directory_path = directory_path || TpCommon::FileStorage.configuration.default_bucket
      end

      private

      # Connection to S3, config in initializer
      def connection
        @connection ||= create_connection
      end

      # Fog directory to bucket config in constructor
      def directory
        @directory ||= connection.directories.get(@directory_path)
      end
    end
  end
end

require 'tp_common/file_storage/errors/failed_to_download'
require 'tp_common/file_storage/errors/file_not_found'

require 'tp_common/file_storage/cleaners/cleaner'
require 'tp_common/file_storage/direct_uploaders/public'
require 'tp_common/file_storage/downloaders/private'
require 'tp_common/file_storage/uploaders/private'
require 'tp_common/file_storage/uploaders/public'
