require "spec_helper"

require 'redis'

RSpec.describe TpCommon::AssetLoaders::RemoteAssetsLoader do
  context 'production env as default' do
    before do
      TpCommon::AssetLoaders::RemoteAssetsLoader.configure do |config|
        config.cdn = 'https://other.hotter.cdn'
      end
      TpCommon::AssetLoaders::RemoteAssetsLoader.load('any-spa': 'v1.0.0')
    end

    it 'return full url' do
      expect(TpCommon::AssetLoaders::RemoteAssetsLoader[:'any-spa']['main.js']).to eq('https://other.hotter.cdn/spa/any-spa/v1.0.0/main.min.js')
    end
  end

  context 'with cache overwrite' do
    before do
      TpCommon::AssetLoaders::RemoteAssetsLoader.configure do |config|
        config.cdn = 'https://other.hotter.cdn'
        config.enable_hot_reload = true
        config.redis_connection = Redis.new
      end
      TpCommon::AssetLoaders::RemoteAssetsLoader.load(:'any-spa', 'v1.0.0')
    end

    context 'no cache set' do
      it 'return full url' do
        expect(TpCommon::AssetLoaders::RemoteAssetsLoader[:'any-spa']['main.js']).to eq('https://other.hotter.cdn/spa/any-spa/v1.0.0/main.min.js')
      end
    end

    context 'with cache' do
      before do
        TpCommon::AssetLoaders::RemoteAssetsLoader.cache_set(:'any-spa', 'cached')
      end
      after do
        TpCommon::AssetLoaders::RemoteAssetsLoader.cache_unset(:'any-spa')
      end

      it 'return cache version url' do
        expect(TpCommon::AssetLoaders::RemoteAssetsLoader[:'any-spa']['main.js']).to eq('https://other.hotter.cdn/spa/any-spa/cached/main.min.js')
      end
    end

    context 'cache then uncache' do
      before do
        TpCommon::AssetLoaders::RemoteAssetsLoader.cache_set(:'any-spa', 'cached')
        TpCommon::AssetLoaders::RemoteAssetsLoader.cache_unset(:'any-spa')
      end

      it 'return full url' do
        expect(TpCommon::AssetLoaders::RemoteAssetsLoader[:'any-spa']['main.js']).to eq('https://other.hotter.cdn/spa/any-spa/v1.0.0/main.min.js')
      end
    end
  end
end
