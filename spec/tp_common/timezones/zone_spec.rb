require 'spec_helper'

RSpec.describe TpCommon::Timezones::Zone do
  before(:all) { TpCommon::Timezones::Config.config }

  describe '#offset' do
    let(:time) { Time.now }
    let(:zone) do
      time_zone = TpCommon::Timezones::LIST_ZONES[key]
      described_class.new(time, key, time_zone[:name], time_zone[:title])
    end
    subject { zone.offset }

    context 'when today is before daylight saving time' do
      let(:time) { Time.new(2018, 3, 10, 12, 00, 00) }
      context 'GMT+12 timezone' do
        let(:key) { 'GMT_P1200' }

        it { is_expected.to eq(0) }
      end

      context 'GMT +9 timezone' do
        let(:key) { 'GMT_P0900' }

        it { is_expected.to eq(3) }
      end

      context 'GMT +0 timezone' do
        let(:key) { 'GMT_M0000' }

        it { is_expected.to eq(12) }
      end

      context 'GMT +0 London timezone' do
        let(:key) { 'GMT_M0000+5' }

        it { is_expected.to eq(12) }
      end

      context 'GMT -9 timezone' do
        let(:key) { 'GMT_M0900' }

        it { is_expected.to eq(21) }
      end

      context 'GMT -9 Alaska timezone' do
        let(:key) { 'GMT_M0900+1' }

        it { is_expected.to eq(21) }
      end

      context 'GMT -12 timezone' do
        let(:key) { 'GMT_M1200' }

        it { is_expected.to eq(24) }
      end
    end

    context 'when today is in 2018 US daylight saving time' do
      let(:time) { Time.new(2018, 3, 12, 12, 00, 00) }
      context 'GMT+12 timezone' do
        let(:key) { 'GMT_P1200' }

        it { is_expected.to eq(0) }
      end

      context 'GMT +9 timezone' do
        let(:key) { 'GMT_P0900' }

        it { is_expected.to eq(3) }
      end

      context 'GMT +0 timezone' do
        let(:key) { 'GMT_M0000' }

        it { is_expected.to eq(12) }
      end

      context 'GMT +0 London timezone' do
        let(:key) { 'GMT_M0000+5' }

        it { is_expected.to eq(12) }
      end

      context 'GMT -9 timezone' do
        let(:key) { 'GMT_M0900' }

        it { is_expected.to eq(21) }
      end

      context 'GMT -9 Alaska timezone' do
        let(:key) { 'GMT_M0900+1' }

        it { is_expected.to eq(20) }
      end

      context 'GMT -12 timezone' do
        let(:key) { 'GMT_M1200' }

        it { is_expected.to eq(24) }
      end
    end

    context 'when today is in 2018 UK daylight saving time' do
      let(:time) { Time.new(2018, 3, 26, 12, 00, 00) }
      context 'GMT+12 timezone' do
        let(:key) { 'GMT_P1200' }

        it { is_expected.to eq(0) }
      end

      context 'GMT +9 timezone' do
        let(:key) { 'GMT_P0900' }

        it { is_expected.to eq(3) }
      end

      context 'GMT +0 timezone' do
        let(:key) { 'GMT_M0000' }

        it { is_expected.to eq(12) }
      end

      context 'GMT +0 London timezone' do
        let(:key) { 'GMT_M0000+5' }

        it { is_expected.to eq(11) }
      end

      context 'GMT -9 timezone' do
        let(:key) { 'GMT_M0900' }

        it { is_expected.to eq(21) }
      end

      context 'GMT -9 Alaska timezone' do
        let(:key) { 'GMT_M0900+1' }

        it { is_expected.to eq(20) }
      end

      context 'GMT -12 timezone' do
        let(:key) { 'GMT_M1200' }

        it { is_expected.to eq(24) }
      end
    end

    context 'when today is after UK daylight saving time' do
      let(:time) { Time.new(2018, 10, 29, 12, 00, 00) }
      context 'GMT+12 timezone' do
        let(:key) { 'GMT_P1200' }

        it { is_expected.to eq(0) }
      end

      context 'GMT +9 timezone' do
        let(:key) { 'GMT_P0900' }

        it { is_expected.to eq(3) }
      end

      context 'GMT +0 timezone' do
        let(:key) { 'GMT_M0000' }

        it { is_expected.to eq(12) }
      end

      context 'GMT +0 London timezone' do
        let(:key) { 'GMT_M0000+5' }

        it { is_expected.to eq(12) }
      end

      context 'GMT -9 timezone' do
        let(:key) { 'GMT_M0900' }

        it { is_expected.to eq(21) }
      end

      context 'GMT -9 Alaska timezone' do
        let(:key) { 'GMT_M0900+1' }

        it { is_expected.to eq(20) }
      end

      context 'GMT -12 timezone' do
        let(:key) { 'GMT_M1200' }

        it { is_expected.to eq(24) }
      end
    end

    context 'when today is after US daylight saving time' do
      let(:time) { Time.new(2018, 11, 5, 12, 00, 00) }
      context 'GMT+12 timezone' do
        let(:key) { 'GMT_P1200' }

        it { is_expected.to eq(0) }
      end

      context 'GMT +9 timezone' do
        let(:key) { 'GMT_P0900' }

        it { is_expected.to eq(3) }
      end

      context 'GMT +0 timezone' do
        let(:key) { 'GMT_M0000' }

        it { is_expected.to eq(12) }
      end

      context 'GMT +0 London timezone' do
        let(:key) { 'GMT_M0000+5' }

        it { is_expected.to eq(12) }
      end

      context 'GMT -9 timezone' do
        let(:key) { 'GMT_M0900' }

        it { is_expected.to eq(21) }
      end

      context 'GMT -9 Alaska timezone' do
        let(:key) { 'GMT_M0900+1' }

        it { is_expected.to eq(21) }
      end

      context 'GMT -12 timezone' do
        let(:key) { 'GMT_M1200' }

        it { is_expected.to eq(24) }
      end
    end
  end

  describe '#date' do
    let(:time) { Time.new(2017, 2, 3, 10, 0, 0) }
    let(:key) { 'GMT_M0700' }

    let(:zone) do
      time_zone = TpCommon::Timezones::LIST_ZONES[key]
      described_class.new(time, key, time_zone[:name], time_zone[:title])
    end

    subject { zone.date }

    it { is_expected.to eq(Date.new(2017, 2, 3)) }
  end

  describe '#key' do
    let(:time) { Time.new(2017, 2, 3, 10, 0, 0) }
    let(:key) { 'GMT_M0700' }

    let(:zone) do
      time_zone = TpCommon::Timezones::LIST_ZONES[key]
      described_class.new(time, key, time_zone[:name], time_zone[:title])
    end

    subject { zone }

    it "exposes key attribute" do
      expect(subject.key).to eq(key)
    end

    it "NOT exposes name attribute" do
      expect{ subject.name }.to raise_error(StandardError)
    end

    it "NOT exposes title attribute" do
      expect{ subject.title }.to raise_error(StandardError)
    end
  end
end
