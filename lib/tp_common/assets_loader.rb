module TpCommon
  class AssetsLoader
    class AssetNotFound < ::StandardError; end
    class ManifestNotFound < ::StandardError; end
    class ManifestFileBroken < ::StandardError; end
    class PackageIsNotLoaded < ::StandardError; end

    LoaderConfiguration = Struct.new(:autoload, :asset_root_path, :version)

    #
    # Clear all config + loaded package
    # Use for test only, but feel free to use in app if need
    def self.clear!
      @config = LoaderConfiguration.new(false, '/public', :latest)
      @packages = {}
    end

    def self.configure
      yield(config)
    end

    def self.build(package_name, external_manifest_file)
      # TODO: Implement
      # Skip if "/public/#{package_name}" exists
      # Download manifest.json from #{external_manifest_file}?version=#{@config.version}
      #                        to "/public/#{package_name}/assets/manifest.json"
      # Validate "/public/#{package_name}/assets/manifest.json"
    end

    def self.load(package_name)
      package_name = package_name.to_sym
      packages[package_name] = new(package_name)
      packages
    end

    def self.[](package_name)
      package_name = package_name.to_sym

      unless packages.key?(package_name)
        if @config.autoload
          load(package_name)
        else
          raise PackageIsNotLoaded.new("Package #{package_name} is not loaded yet.")
        end
      end

      packages[package_name]
    end

    def self.asset_root_path
      @config.asset_root_path
    end

    def self.packages
      @packages ||= {}
    end

    def self.new_config
      LoaderConfiguration.new(false, '/public', :latest)
    end

    def self.config
      @config ||= new_config
    end

    private_class_method :packages, :new_config, :config

    def initialize(package_name)
      @package_name = package_name.to_sym
      file_path = File.join(self.class.asset_root_path, @package_name.to_s, 'assets', 'manifest.json')

      @manifest = begin
                    JSON.parse(File.read(file_path))
                  rescue SystemCallError
                    raise ManifestNotFound.new(
                      "Unable to load manifest file for package #{@package_name} at: #{file_path}"
                    )
                  rescue StandardError
                    raise ManifestFileBroken.new("Manifest file for package #{@package_name} is unable to load")
                  end
      return true
    end

    def [](asset_name)
      @manifest[asset_name].tap do |asset|
        if asset.nil?
          raise AssetNotFound.new("Asset #{@package_name}/#{asset_name} is not found.")
        end
      end
    end
  end
end
