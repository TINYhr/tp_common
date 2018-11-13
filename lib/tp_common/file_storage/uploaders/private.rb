module TpCommon
  module FileStorage
    module Uploaders
      # Upload a content to file storage used for private purpose like user import. export files
      # Use in case content to upload is inside of system/server
      #
      class Private < FileStorage::Base
        # Upload content to file_key
        #
        def upload(file_key, content, content_type)
          retry_count = 0

          begin
            directory.files.create(
              'key' => mask_key(file_key),
              "body" =>  content,
              'public' =>  false,
              'Content-Type' => content_type,
              "Content-Disposition" => "attachment;filename=\"#{mask_key(file_key)}\""
            )
          rescue StandardError => e
            retry_count += 1
            retry if retry_count < MAX_RETRIES
            raise e
          end

          mask_key(file_key)
        end
        # Get url from key of file #upload above to provide to outside.
        #   To get file content to use inside system, please use Downloaders::Private instead
        # As private file, link has a ttl, default 1 week.
        #
        def url(file_key, link_ttl = 1.week.from_now)
          directory.files.get_https_url(mask_key(file_key), link_ttl)
        end
      end
    end
  end
end
