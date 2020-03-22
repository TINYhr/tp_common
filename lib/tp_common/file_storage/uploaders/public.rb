module TpCommon
  module FileStorage
    module Uploaders
      # Upload a content to file storage used to public like avatar, logo
      # Use in case content to upload is inside of system/server
      #
      class Public < FileStorage::Base
        # Upload content to file_key
        # Currently, _content_type is ignore but kept for compatible. Will be removed in next release
        #
        def upload(file_key, content, _content_type = nil)
          retry_count = 0

          begin
            directory.files.create(
              key: mask_key(file_key),
              body: content,
              public: true)
          rescue StandardError => e
            retry_count += 1
            retry if retry_count < MAX_RETRIES
            raise e
          end

          mask_key(file_key)
        end

        # Get public url from key of file #upload above
        #
        def url(file_key)
          directory.files.get(mask_key(file_key))&.public_url
        end

        # @param file_key [String]
        def exists?(file_key)
          !!directory.files.head(mask_key(file_key))
        end
      end
    end
  end
end
