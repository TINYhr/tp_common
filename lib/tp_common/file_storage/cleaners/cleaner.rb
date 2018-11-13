module TpCommon
  module FileStorage
    module Cleaners
      # Delete files on file storage service.
      # Please handle with care
      #
      class Cleaner < FileStorage::Base
        # Expect an array of file key to delete.
        #
        def clean(files)
          connection.delete_multiple_objects(@directory_path, files.map{|file_key| mask_key(file_key) })
        end
      end
    end
  end
end
