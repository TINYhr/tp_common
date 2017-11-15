require "spec_helper"

RSpec.describe TpCommon::Timezones do
  describe '.current_date_in_time_zone' do
    subject { described_class.current_date_in_time_zone(zone_name) }

    context "UTC morning time" do
      before { Timecop.freeze(Time.new(2017, 12, 1, 10, 0, 0, "-00:00")) }
      after { Timecop.return }

      context 'timezone GMT_M1200' do
        let(:zone_name) { 'GMT_M1200' }
        it { is_expected.to eq(Date.new(2017, 11, 30)) }
      end

      context 'timezone GMT_M0000' do
        let(:zone_name) { 'GMT_M0000' }
        it { is_expected.to eq(Date.new(2017, 12, 1)) }
      end

      context 'timezone GMT_P1200' do
        let(:zone_name) { 'GMT_P1200' }
        it { is_expected.to eq(Date.new(2017, 12, 1)) }
      end
    end

    context "UTC afternoon time" do
      before { Timecop.freeze(Time.new(2017, 12, 1, 14, 0, 0, "-00:00")) }
      after { Timecop.return }

      context 'timezone GMT_M1200' do
        let(:zone_name) { 'GMT_M1200' }
        it { is_expected.to eq(Date.new(2017, 12, 1)) }
      end

      context 'timezone GMT_M0000' do
        let(:zone_name) { 'GMT_M0000' }
        it { is_expected.to eq(Date.new(2017, 12, 1)) }
      end

      context 'timezone GMT_P1200' do
        let(:zone_name) { 'GMT_P1200' }
        it { is_expected.to eq(Date.new(2017, 12, 2)) }
      end
    end
  end

  describe '.offset_in_words' do
    subject { described_class.offset_in_words(zone_name) }
    before { Timecop.freeze(now) }

    context 'without DST' do
      let(:now) { Time.new(2015, 12, 1, 0, 0, 0) }
      context 'when zone_name is UTC' do

        let(:zone_name) { 'UTC' }
        it{ is_expected.to eq('GMT-0') }
      end
      context 'when zone_name is Asia/Tehran' do
        let(:zone_name) { 'Asia/Tehran' }
        it{ is_expected.to eq('GMT+3') }
      end
      context 'when zone_name is America/Phoenix' do
        let(:zone_name) { 'America/Los_Angeles' }
        it{ is_expected.to eq('GMT-8') }
      end
    end

    context 'with DST' do
      let(:now) { Time.new(2015, 4, 1, 0, 0, 0) }
      context 'when zone_name is UTC' do
        let(:zone_name) { 'UTC' }
        it{ is_expected.to eq('GMT-0') }
      end
      context 'when zone_name is Asia/Tehran' do
        let(:zone_name) { 'Asia/Tehran' }
        it{ is_expected.to eq('GMT+4') }
      end
      context 'when zone_name is America/Phoenix' do
        let(:zone_name) { 'America/Los_Angeles' }
        it{ is_expected.to eq('GMT-7') }
      end
    end
  end

  describe '.zone_title .zone_title_without_dst' do
    context 'when time_zone_key is in list zones' do
      context 'time zone with DST' do
        let(:time_zone_key) { 'GMT_M0000+5' }

        it ".zone_title render with DST icon" do
          expect(described_class.zone_title(time_zone_key)).to eq('London GMT-0 ☀️')
        end
        it ".zone_title_without_dst render without DST icon" do
          expect(described_class.zone_title_without_dst(time_zone_key)).to eq('London GMT-0')
        end
      end

      context 'time zone without DST' do
        let(:time_zone_key) { 'GMT_M0000+6' }

        it ".zone_title render without DST icon" do
          expect(described_class.zone_title(time_zone_key)).to eq('Monrovia GMT-0')
        end
        it ".zone_title_without_dst render without DST icon" do
          expect(described_class.zone_title_without_dst(time_zone_key)).to eq('Monrovia GMT-0')
        end
      end
    end

    context 'when time_zone_key is not in list zones' do
      let(:time_zone_key) { 'test' }

      it ".zone_title render nothing" do
        expect(described_class.zone_title(time_zone_key)).to be_nil
      end
      it ".zone_title_without_dst render nothing" do
        expect(described_class.zone_title_without_dst(time_zone_key)).to be_nil
      end
    end
  end

  describe '.list_for_select' do
    subject{ described_class.list_for_select }

    it 'render key value as array' do
      expect(subject.first).to eq(["GMT-12", "GMT_M1200"])
      expect(subject.last).to eq(["Wellington GMT+12", "GMT_P1200+5"])
    end

    it 'has format accepted by select tag' do
      subject.each do|item|
        expect(item[0]).to be_a(String)
        expect(item[1]).to be_a(String)
      end
    end
  end

  describe '.local_to_utc' do
    subject { described_class.local_to_utc(test_time, zone_key) }

    context "10 am GMT+7 time now" do
      let(:test_time) { Time.new(2017, 12, 1, 10, 0, 0, "+07:00") }
      let(:zone_key) { 'GMT_P0700' }

      it { is_expected.to eq(Time.new(2017, 12, 1, 3, 0, 0, "-00:00"))}
    end

    context "10 am GMT time now" do
      let(:test_time) { Time.new(2017, 12, 1, 10, 0, 0, "+00:00") }
      let(:zone_key) { 'GMT_M0000' }

      it { is_expected.to eq(Time.new(2017, 12, 1, 10, 0, 0, "-00:00"))}
    end

    context "10am GMT-7 time now" do
      let(:test_time) { Time.new(2017, 12, 1, 10, 0, 0, "-07:00") }
      let(:zone_key) { 'GMT_M0700' }

      it { is_expected.to eq(Time.new(2017, 12, 1, 17, 0, 0, "-00:00"))}
    end
  end

  describe '.converted_time' do
    subject { described_class.converted_time(test_time, zone_key) }

    context 'no time passed' do
      let(:test_time) { nil }
      let(:zone_key) { 'GMT_P0700' }

      it { is_expected.to be_nil }
    end

    context 'time passed as argument' do
      let(:test_time) { Time.new(2017, 12, 1, 10, 0, 0, "-00:00") }

      context 'in GMT- zone' do
        let(:zone_key) { 'GMT_M0700' }

        it { is_expected.to eq(Time.new(2017, 12, 1, 3, 0, 0, "-07:00")) }
      end

      context 'in GMT+ zone' do
        let(:zone_key) { 'GMT_P0700' }

        it { is_expected.to eq(Time.new(2017, 12, 1, 17, 0, 0, "+07:00")) }
      end

      context 'invalid zone' do
        let(:zone_key) { 'GMT_K0700' }

        it 'return time entered' do
          expect(subject).to eq(Time.new(2017, 12, 1, 10, 0, 0, "-00:00"))
        end
      end
    end
  end

  describe '.zone_abbreviation' do
    subject { described_class.zone_abbreviation(zone_key) }

    context "Generic time zone key" do
      let(:zone_key) { 'GMT_M0700' }

      it { is_expected.to eq('Etc/GMT+7') }
    end

    context "Detail time zone key" do
      let(:zone_key) { 'GMT_M0700+1' }

      it { is_expected.to eq('Etc/GMT+7') }
    end

    context "Invalid time zone key" do
      let(:zone_key) { 'GMT_K0700' }

      it "raise exception" do
        expect{ subject }.to raise_error(NoMethodError)
      end
    end
  end

  describe '.relative_time_in_time_zone' do
    subject { described_class.relative_time_in_time_zone(test_time, zone_key) }
    let(:test_time) { Time.new(2017, 12, 1, 10, 0, 0, "+00:00") }

    context "10 am GMT+7 time now" do
      let(:zone_key) { 'GMT_P0700' }

      it { is_expected.to eq(DateTime.new(2017, 12, 1, 10, 0, 0, "+07:00"))}
    end

    context "10 am GMT time now" do
      let(:zone_key) { 'GMT_M0000' }

      it { is_expected.to eq(DateTime.new(2017, 12, 1, 10, 0, 0, "+00:00"))}
    end

    context "10am GMT-7 time now" do
      let(:zone_key) { 'GMT_M0700' }

      it { is_expected.to eq(DateTime.new(2017, 12, 1, 10, 0, 0, "-07:00"))}
    end
  end
end
