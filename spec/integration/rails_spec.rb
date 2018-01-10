require "rails_helper"

begin
  require 'rails'
  RAILS_PRESENT = true
rescue LoadError
  RAILS_PRESENT = false
  puts 'Skipping Rails integration specs.'
end

if RAILS_PRESENT
  require FIXTURES_PATH.join('rails', 'config', 'application.rb').to_s
  require 'rspec/rails'

  RSpec.describe 'Rails integration', type: :request do
    before(:all) do
      RailsApp.initialize!
    end

    it "run rails app" do
      get '/'
      expect(response.status).to eq(200)
    end

    context 'rails app has NO config/timezones.yml' do
      it "has 158 zones" do
        get '/list_count'

        expect(response.status).to eq(200)
        expect(response.body).to eq("158")
      end

      let(:first_zone) do
        {
          "key"   => "GMT_M1200",
          "zone"  => {
            "title" => "",
            "name"  => "Etc/GMT+12",
            "dst"   => false
          }
        }
      end
      it "has default first zone" do
        get '/first_zone'

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(first_zone)
      end

      # These actions depend on ActiveSupport
      include_examples 'local_to_utc'
      include_examples 'relative_time_in_time_zone'
      include_examples 'offset_in_words'
      include_examples 'converted_time'
    end
  end
end
