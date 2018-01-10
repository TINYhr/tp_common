RSpec.shared_examples "offset_in_words" do
  describe '.offset_in_words' do
    context 'without DST' do
      before { Timecop.freeze(Time.new(2015, 12, 1, 0, 0, 0)) }

      context 'when zone_name is UTC' do
        it "returns correct" do
          get '/offset_in_words/test_1'

          expect(response.status).to eq(200)
          expect(response.body).to eq("GMT-0")
        end
      end
      context 'when zone_name is Asia/Tehran' do
        it "returns correct" do
          get '/offset_in_words/test_2'

          expect(response.status).to eq(200)
          expect(response.body).to eq("GMT+3")
        end
      end
      context 'when zone_name is America/Los_Angeles' do
        it "returns correct" do
          get '/offset_in_words/test_3'

          expect(response.status).to eq(200)
          expect(response.body).to eq("GMT-8")
        end
      end
    end

    context 'with DST' do
      before { Timecop.freeze(Time.new(2015, 4, 1, 0, 0, 0)) }

      context 'when zone_name is UTC' do
        it "returns correct" do
          get '/offset_in_words/test_1'

          expect(response.status).to eq(200)
          expect(response.body).to eq("GMT-0")
        end
      end
      context 'when zone_name is Asia/Tehran' do
        it "returns correct" do
          get '/offset_in_words/test_2'

          expect(response.status).to eq(200)
          expect(response.body).to eq("GMT+4")
        end
      end
      context 'when zone_name is America/Los_Angeles' do
        it "returns correct" do
          get '/offset_in_words/test_3'

          expect(response.status).to eq(200)
          expect(response.body).to eq("GMT-7")
        end
      end
    end
  end
end
