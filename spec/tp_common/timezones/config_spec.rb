require 'spec_helper'

RSpec.describe TpCommon::Timezones::Config do
  describe ".config" do
    context 'in rails apps' do
      # Ref integration tests
    end

    context 'NOT rails apps' do
      it "has 158 zones" do
        described_class.config

        expect(TpCommon::Timezones::LIST_ZONES.size).to eq(158)
      end

      it "has string keys" do
        described_class.config

        TpCommon::Timezones::LIST_ZONES.keys.each do|key|
          expect(key).to be_a(String)
        end
      end

      it "has symbol keys for each item" do
        described_class.config

        TpCommon::Timezones::LIST_ZONES.each do|key, zone|
          zone.keys.each do|key|
            expect(key).to be_a(Symbol)
          end

          expect(zone[:name]).not_to be_nil
          expect(zone[:title]).not_to be_nil
          expect(zone[:dst]).not_to be_nil
        end
      end

      it 'has 344 reversed look up as default' do
        described_class.config

        expect(TpCommon::Timezones::REVERSED_LIST_ZONES.count).to eq(344)
      end
    end
  end
end
