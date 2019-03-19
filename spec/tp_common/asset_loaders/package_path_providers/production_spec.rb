require 'spec_helper'

RSpec.describe TpCommon::AssetLoaders::PackagePathProviders::Production do
  it 'return full url' do
    provider = described_class.new('https://other.hotter.cdn', 'http://dev.localhost:3001')

    expect(provider.asset_url(:'any-spa', 'v1.0.0', 'main.js')).to eq('https://other.hotter.cdn/spa/any-spa/v1.0.0/main.min.js')
  end
end
