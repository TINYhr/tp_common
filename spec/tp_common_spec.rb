require "spec_helper"

RSpec.describe TpCommon do
  it "has a version number" do
    expect(TpCommon::VERSION).not_to be nil
  end

  describe ".load_timezones" do
    it "has 158 zones" do
      expect(TpCommon.load_timezones.size).to eq(158)
    end

    it "has string keys" do
      TpCommon.load_timezones.keys.each do|key|
        expect(key).to be_a(String)
      end
    end

    it "has symbol keys for each item" do
      TpCommon.load_timezones.each do|key, zone|
        zone.keys.each do|key|
          expect(key).to be_a(Symbol)
        end

        expect(zone[:name]).not_to be_nil
        expect(zone[:title]).not_to be_nil
        expect(zone[:dst]).not_to be_nil
      end
    end

    context 'in rails apps' do
      context 'rails version not support `config_for`'
      context 'rails version support `config_for`' do
        context 'rails app has NO config/timezones.yml'
        context 'rails app has invalid config/timezones.yml'
        context 'rails app has valid config/timezones.yml'
      end
    end
  end
end
