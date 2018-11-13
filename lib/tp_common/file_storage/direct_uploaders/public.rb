module TpCommon
  module FileStorage
    module DirectUploaders
      # Prepare a presigned url to upload diectly to storage service
      # Use in case content to upload is outside of system/server,
      #   we shoud use this to avoid delay because of content stream over our server
      #
      class Public < FileStorage::Base
        def initialize(bucket_name = nil)
          @bucket_name = bucket_name || TpCommon::FileStorage.configuration.default_bucket
          @bucket = Aws::S3::Bucket.new(name: @bucket_name)
        end

        # Presigned POST url, use for form POST with data. Use when file name isn't decided yet
        # Request body is form data
        # Return a hash
        #
        def presigned_post(file_key)
          s3_direct_post = @bucket.presigned_post(key: mask_key(file_key),
                                                  success_action_status: '201',
                                                  acl: 'public-read')
          {
            host: URI(s3_direct_post.url).host,
            bucket: @bucket_name,
            url: "#{s3_direct_post.url}/",
            form_data: s3_direct_post.fields
          }
        end

        # Presigned PUT url, use for PUT file to storage service.
        # File name must be matched, and request body is file content
        # Return a hash
        #
        def presigned_put(file_key, mime_type, expires_in = 900)
          @bucket.object(mask_key(file_key)).presigned_url(:put,
                                            content_type: mime_type,
                                            acl: 'public-read',
                                            expires_in: expires_in)
        end

        # Public URL from key for uploaded file
        #
        def url(file_key)
          @bucket.object(mask_key(file_key))&.public_url(path_style: true)
        end
      end
    end
  end
end
