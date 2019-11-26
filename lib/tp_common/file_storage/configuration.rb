require 'aws-sdk-s3'
require 'fog/aws'

module TpCommon
  module FileStorage
    class Configuration
      def initialize(aws_region,
                     aws_key_id = nil,
                     aws_secret_key = nil,
                     key_prefix = nil,
                     default_bucket = nil)

        @aws_region = aws_region
        @aws_key_id = aws_key_id
        @aws_secret_key = aws_secret_key
        @key_prefix = key_prefix
        @default_bucket = default_bucket
      end

      attr_accessor :aws_region,
                    :aws_key_id,
                    :aws_secret_key,
                    :key_prefix,
                    :default_bucket

      def connection
        @connection ||= Fog::Storage.new(provider: 'AWS',
          aws_access_key_id: aws_key_id,
          aws_secret_access_key: aws_secret_key)
      end

      def get_directory(directory_path)
        cached_directories[directory_path.to_sym]
      end

      private

      def cached_directories
        @cached_directories ||= Hash.new do |hash, key|
          hash[key] = connection.directories.get(key.to_s)
        end
      end
    end
  end
end
