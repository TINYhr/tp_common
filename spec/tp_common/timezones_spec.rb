require "spec_helper"

RSpec.describe TpCommon::Timezones do
  describe '#offset_in_words' do
    subject{ TpCommon::Timezones.offset_in_words(zone_name) }

    before do
      Timecop.freeze(now)
    end

    context 'without DST' do
      let(:now) { Time.new(2015, 12, 1, 0, 0, 0) }
      context 'when zone_name is UTC' do

        let(:zone_name) { 'UTC' }
        it{ should eql 'GMT-0' }
      end
      context 'when zone_name is Asia/Tehran' do
        let(:zone_name) { 'Asia/Tehran' }
        it{ should eql 'GMT+3' }
      end
      context 'when zone_name is America/Phoenix' do
        let(:zone_name) { 'America/Los_Angeles' }
        it{ should eql 'GMT-8' }
      end
    end

    context 'with DST' do
      let(:now) { Time.new(2015, 4, 1, 0, 0, 0) }
      context 'when zone_name is UTC' do
        let(:zone_name) { 'UTC' }
        it{ should eql 'GMT-0' }
      end
      context 'when zone_name is Asia/Tehran' do
        let(:zone_name) { 'Asia/Tehran' }
        it{ should eql 'GMT+4' }
      end
      context 'when zone_name is America/Phoenix' do
        let(:zone_name) { 'America/Los_Angeles' }
        it{ should eql 'GMT-7' }
      end
    end
  end

  describe '#list_for_select' do
    before do
      zones = {
        'GMT_M0000' => { title: 'London', name: 'Etc/GMT+0' }
      }
      stub_const("TpCommon::Timezones::LIST_ZONES", zones)
      allow(TpCommon::Timezones).to receive(:zone_title).and_return('London GMT')
    end

    subject{ TpCommon::Timezones.list_for_select }

    it 'should include title and key' do
      timezone = subject.first
      # title
      expect(timezone.first).to eql 'London GMT'
      # key
      expect(timezone.last).to eql 'GMT_M0000'
    end
  end

  describe '#zone_title' do
    subject{ TpCommon::Timezones.zone_title(time_zone_key) }

    context 'when time_zone_key is in list zones' do
      context 'time zone with DST' do
        let(:time_zone_key) { 'GMT_M0000+5' }

        it{ should eq('London GMT-0 ☀️') }
      end

      context 'time zone without DST' do
        let(:time_zone_key) { 'GMT_M0000+6' }

        it{ should eq('Monrovia GMT-0') }
      end
    end

    context 'when time_zone_key is not in list zones' do
      let(:time_zone_key) { 'test' }
      subject{ TpCommon::Timezones.zone_title(time_zone_key) }

      it{ should be_nil }
    end
  end
end
