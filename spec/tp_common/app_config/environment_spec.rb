require "spec_helper"

RSpec.describe TpCommon::AppConfig::Environment do
  before do
    described_class.clear! # To make sure config are re-evaluated after each test
    allow(Bundler).to receive(:root).and_return(File.join(File.dirname(__FILE__)))
  end

  context 'from app_config.yml' do
    it 'return value' do
      expect(described_class.fetch(:'app.name')).to eq('test')
      expect(described_class.fetch(:'app.empty_name')).to eq(nil)
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
      expect(described_class.fetch(:'app.name')).to eq('overwritten_test')
      expect(described_class.fetch(:'app.empty_name')).to eq('overwritten_test2')
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
        expect(described_class.fetch(:'app.name2')).to eq(nil)
        expect(described_class.fetch(:'app.empty_name2')).to eq(nil)
      end
    end
  end
end
