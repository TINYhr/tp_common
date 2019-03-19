require 'spec_helper'
require 'tp_common/asset_loaders/package_path_providers/development'

RSpec.describe TpCommon::AssetLoaders::PackagePathProviders::Development do
  context 'dev server response' do
    before do
      WebMock.enable!
      stub_request(:any, 'http://dev.localhost:3001/any-spa/_ping').to_return(status: 200, body: "{}")
    end
    after do
      WebMock.disable!
    end
    it 'return full url for dev server' do
      provider = described_class.new('https://other.hotter.cdn', 'http://dev.localhost:3001')

      expect(provider.asset_url(:'any-spa', 'v1.0.0', 'main.js')).to eq('http://dev.localhost:3001/any-spa/main.js')
    end
  end

  context 'dev server response not found' do
    before do
      WebMock.enable!
      stub_request(:any, 'http://dev.localhost:3001/any-spa/_ping').to_return(status: 404, body: "")
    end
    after do
      WebMock.disable!
    end
    it 'return full url' do
      provider = described_class.new('https://other.hotter.cdn', 'http://dev.localhost:3001')

      expect(provider.asset_url(:'any-spa', 'v1.0.0', 'main.js')).to eq('https://other.hotter.cdn/spa/any-spa/v1.0.0/main.min.js')
    end
  end
end
