RSpec.shared_examples "local_to_utc" do
  describe '.local_to_utc' do
    before { Timecop.freeze(Time.new(2017, 12, 1, 14, 0, 0, "-00:00")) }
    after { Timecop.return }

    context "10 am GMT+7 time now" do
      it "returns correct" do
        get '/local_to_utc/test_1'

        expect(response.status).to eq(200)
        expect(response.body).to eq("true")
      end
    end

    context "10 am GMT time now" do
      it "returns correct" do
        get '/local_to_utc/test_2'

        expect(response.status).to eq(200)
        expect(response.body).to eq("true")
      end
    end

    context "10 am GMT-7 time now" do
      it "returns correct" do
        get '/local_to_utc/test_3'

        expect(response.status).to eq(200)
        expect(response.body).to eq("true")
      end
    end
  end
end
