module TpCommon
  module FileStorage
    # Provide mechanism to protect keys conflict using prefix
    # This module supports using 1 bucket for multiple environment, just have different prefix key
    # Although it's recommended in real usage, using in development env is recommended.
    #   To avoid issue local uploading works but trouble when work with S3
    module KeyProtector

      private

      # Mask key with s3 dev prefix. !!! Make sure it's idempotent
      #
      def mask_key(key)
        return key if !FileStorage.key_prefix

        # Trim and remove redundant slash
        key = key.gsub(/^\/*/, '').gsub(/\/*$/, '').gsub(/\/+/, '/')
        regex = Regexp.new("^#{FileStorage.key_prefix}/")
        return key if regex.match(key)

        "#{FileStorage.key_prefix}/#{key}"
      end
    end
  end
end
