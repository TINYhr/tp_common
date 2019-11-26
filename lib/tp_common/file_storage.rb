require 'aws-sdk-s3'
require 'tp_common/file_storage/configuration'

module TpCommon
  module FileStorage
    def self.configure
      @configuration = TpCommon::FileStorage::Configuration.new('us-east-1')

      yield(@configuration)

      Aws.config.update({
        region: @configuration.aws_region,
        credentials: Aws::Credentials.new(
          @configuration.aws_key_id,
          @configuration.aws_secret_key)
      })
    end

    def self.key_prefix
      raise ::StandardError.new('FileStorage is not config yet.') unless defined?(@configuration)

      @configuration.key_prefix
    end

    def self.configuration
      raise ::StandardError.new('FileStorage is not config yet.') unless defined?(@configuration)

      @configuration
    end
  end
end

require 'tp_common/file_storage/base'
