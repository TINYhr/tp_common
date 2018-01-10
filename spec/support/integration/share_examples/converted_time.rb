RSpec.shared_examples "converted_time" do
  describe '.converted_time' do
    context 'no time passed' do
      it "returns correct" do
        get '/converted_time/test_1'

        expect(response.status).to eq(200)
        expect(response.body).to eq("true")
      end
    end

    context 'time passed as argument' do
      context 'in GMT- zone' do
        it "returns correct" do
          get '/converted_time/test_2'

          expect(response.status).to eq(200)
          expect(response.body).to eq("true")
        end
      end

      context 'in GMT+ zone' do
        it "returns correct" do
          get '/converted_time/test_3'

          expect(response.status).to eq(200)
          expect(response.body).to eq("true")
        end
      end

      context 'invalid zone' do
        it "returns correct" do
          get '/converted_time/test_4'

          expect(response.status).to eq(200)
          expect(response.body).to eq("true")
        end
      end
    end
  end
end
