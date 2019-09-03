require 'spec_helper'

RSpec.describe TpCommon::Timezones::Reversed do
  before(:all) { TpCommon::Timezones::Config.config }

  it 'support GMT+5.5 tz' do
    expect(described_class['GMT+5.5']).to eq(:GMT_P0500)
  end

  it 'support common tz abbreviation' do
    expect(described_class['PST']).to eq(:'GMT_M0800+1')
  end

  it 'support common name tz' do
    expect(described_class['Chihuahua']).to eq(:'GMT_M0700+2')
  end

  it 'return nil for invalid name' do
    expect(described_class['InvalidTz']).to eq(nil)
  end
end
