module TpCommon
  module FileStorage
    module Downloaders
      # Pull and read a files from storage service.
      # Included retry mechanism.
      #
      class Private < FileStorage::Base
        # Pull a file with provided key.
        # Return a Fog file object https://www.rubydoc.info/github/fog/fog-aws/Fog/Storage/AWS/File
        # @param file_key [String]
        def download(file_key)
          retried_count = 0
          begin
            directory.files.get(mask_key(file_key)).tap do |file|
              raise FileStorage::Errors::FileNotFound.new("Could not find file: #{file_key}") unless file
            end
          rescue ::Fog::Errors::Error => error
            retried_count += 1
            retry if retried_count < MAX_RETRIES
            raise FileStorage::Errors::FailedToDownload.new("Failed to download file via fog: #{error.message}")
          end
        end

        # Same as #download but return file content
        # @param file_key [String]
        def read(file_key)
          download(mask_key(file_key)).body
        end

        # @param file_key [String]
        def exists?(file_key)
          !!directory.files.head(mask_key(file_key))
        end
      end
    end
  end
end
