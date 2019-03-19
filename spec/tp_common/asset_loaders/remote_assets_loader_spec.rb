require "spec_helper"

RSpec.describe TpCommon::AssetLoaders::RemoteAssetsLoader do
  before do
    TpCommon::AssetLoaders::RemoteAssetsLoader.configure do |config|
      config.cdn = 'https://other.hotter.cdn'
    end
    TpCommon::AssetLoaders::RemoteAssetsLoader.load(:'any-spa', 'v1.0.0')
  end

  context 'production env as default' do
    it 'return full url' do
      expect(TpCommon::AssetLoaders::RemoteAssetsLoader[:'any-spa']['main.js']).to eq('https://other.hotter.cdn/spa/any-spa/v1.0.0/main.min.js')
    end
  end
end
