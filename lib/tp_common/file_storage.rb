require 'aws-sdk-s3'

module TpCommon
  module FileStorage
    Configuration = Struct.new(:aws_region,
                               :aws_key_id,
                               :aws_secret_key,
                               :key_prefix,
                               :default_bucket)

    def self.configure
      @configuration = Configuration.new('us-east-1', nil, nil, nil, nil)

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
