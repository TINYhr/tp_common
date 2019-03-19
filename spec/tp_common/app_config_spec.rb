require "spec_helper"

# Copy from unit test of TpCommon::AppConfig::Environment as we support environment config only.
RSpec.describe TpCommon::AppConfig do
  before do
    TpCommon::AppConfig::Environment.clear! # To make sure config are re-evaluated after each test
    allow(Bundler).to receive(:root).and_return(File.join(File.dirname(__FILE__), 'app_config'))
  end

  context 'from app_config.yml' do
    it 'return value' do
      expect(TpCommon::AppConfig[:'app.name']).to eq('test')
      expect(TpCommon::AppConfig[:'app.empty_name']).to eq(nil)
    end
  end

  context 'from ENV' do
    before do
      ENV['APP__NAME'] = 'overwritten_test'
      ENV['APP__EMPTY_NAME'] = 'overwritten_test2'
    end

    after do
      ENV['APP__NAME'] = nil
      ENV['APP__EMPTY_NAME'] = nil
    end

    it 'return value in app_config.yml' do
      expect(TpCommon::AppConfig[:'app.name']).to eq('overwritten_test')
      expect(TpCommon::AppConfig[:'app.empty_name']).to eq('overwritten_test2')
    end

    context 'NOT defined in app_config.yml' do
      before do
        ENV['APP__NAME2'] = 'overwritten_test'
        ENV['APP__EMPTY_NAME2'] = 'overwritten_test2'
      end
      after do
        ENV['APP__NAME'] = nil
        ENV['APP__EMPTY_NAME'] = nil
      end

      it 'return value in app_config.yml' do
        expect(TpCommon::AppConfig[:'app.name2']).to eq(nil)
        expect(TpCommon::AppConfig[:'app.empty_name2']).to eq(nil)
      end
    end
  end
end
