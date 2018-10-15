require "spec_helper"

RSpec.describe TpCommon::AssetsLoader do
  before { described_class.clear! }
  context 'auto load' do
    context 'asset path exists' do
      before do
        described_class.configure do |config|
          config.autoload = true
          config.asset_root_path = File.join('spec', 'fixtures', 'asset_loader')
        end
      end

      context 'manifest file is correct' do
        it 'load correct asset' do
          expect(described_class[:mocky_package]['main.js']).to eq('/somewhere/main-averylonghashstring2.min.js')
        end
      end

      context 'manifest file is corrupted' do
        it 'raise error with package name' do
          expect { described_class[:corrupted_package]['main.js'] }.to raise_error(
            described_class::ManifestFileBroken, /corrupted_package/
          )
        end
      end
    end

    context 'asset path NOT exists' do
      before do
        described_class.configure do |config|
          config.autoload = true
          config.asset_root_path = File.join('spec', 'fixtures', 'asset_loader', 'black_hole')
        end
      end

      it 'raise error with path' do
        expect { described_class[:corrupted_package]['main.js'] }.to raise_error(described_class::ManifestNotFound,
                                                                                 /asset_loader\/black_hole/)
      end
    end
  end

  context 'manually load' do
    context 'package isnt loaded' do
      context 'asset path exists' do
        before do
          described_class.configure do |config|
            config.autoload = false
            config.asset_root_path = File.join('spec', 'fixtures', 'asset_loader')
          end
        end

        context 'manifest file is correct' do
          it 'raise error with package name' do
            expect { described_class[:mocky_package]['main.js'] }.to raise_error(described_class::PackageIsNotLoaded,
                                                                                 /mocky_package/)
          end
        end

        context 'manifest file is corrupted' do
          it 'raise error with package name' do
            expect { described_class[:corrupted_package]['main.js'] }.to raise_error(
              described_class::PackageIsNotLoaded, /corrupted_package/
            )
          end
        end
      end

      context 'asset path NOT exists' do
        before do
          described_class.configure do |config|
            config.autoload = false
            config.asset_root_path = File.join('spec', 'fixtures', 'asset_loader', 'black_hole')
          end
        end

        context 'manifest file is correct' do
          it 'raise error with package name' do
            expect { described_class[:mocky_package]['main.js'] }.to raise_error(described_class::PackageIsNotLoaded,
                                                                                 /mocky_package/)
          end
        end
      end
    end

    context 'package loadeded' do
      context 'asset path exists' do
        before do
          described_class.configure do |config|
            config.autoload = false
            config.asset_root_path = File.join('spec', 'fixtures', 'asset_loader')
          end
        end

        context 'manifest file is correct' do
          it 'load correct asset' do
            expect { described_class.load(:mocky_package) }.not_to raise_error
            expect(described_class[:mocky_package]['main.js']).to eq('/somewhere/main-averylonghashstring2.min.js')
          end
        end

        context 'manifest file is corrupted' do
          it 'raise error with package name' do
            expect { described_class.load(:corrupted_package) }.to raise_error(described_class::ManifestFileBroken,
                                                                               /corrupted_package/)
            expect { described_class[:corrupted_package]['main.js'] }.to raise_error(
              described_class::PackageIsNotLoaded, /corrupted_package/
            )
          end
        end
      end

      context 'asset path NOT exists' do
        before do
          described_class.configure do |config|
            config.autoload = false
            config.asset_root_path = File.join('spec', 'fixtures', 'asset_loader', 'black_hole')
          end
        end

        context 'manifest file is correct' do
          it 'raise error with path' do
            expect { described_class.load(:mocky_package) }.to raise_error(described_class::ManifestNotFound,
                                                                           /asset_loader\/black_hole/)
            expect { described_class[:mocky_package]['main.js'] }.to raise_error(described_class::PackageIsNotLoaded,
                                                                                 /mocky_package/)
          end
        end
      end
    end
  end
end
