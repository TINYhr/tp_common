require 'spec_helper'

RSpec.describe TpCommon::FileStorage::DirectUploaders::Public do
  let(:access_key_id) { '__MOCK_ACCESS_KEY_ID__' }
  let(:secret_access_key) { '__MOCK_SECRET_ACCESS_KEY__' }
  let(:default_bucket) { 'tinypulse-default-bucket'}

  before do
    Fog.mock!
    Fog::Mock.reset
    TpCommon::FileStorage.configure do|configuration|
      configuration.aws_key_id      = access_key_id
      configuration.aws_secret_key  = secret_access_key
      configuration.default_bucket  = default_bucket
    end
  end
  after { Fog.unmock! }

  let(:conn) do
    Fog::Storage.new(provider: 'AWS',
      aws_access_key_id: access_key_id,
      aws_secret_access_key: secret_access_key)
  end

  context 'default bucket' do
    subject { described_class.new }

    describe 'url for form post' do
      it 'return hash info' do
        hash_info = subject.presigned_post('file1')

        expect(hash_info).to be
        expect(hash_info[:url]).to    start_with('https://')
        expect(hash_info[:host]).to   be
        expect(hash_info[:bucket]).to be # eq(DEFAULT_BUCKET_NAME)

        expect(hash_info[:form_data]["policy"]).to  be
        expect(hash_info[:form_data]["key"]).to     eq('file1')
        expect(hash_info[:form_data]["acl"]).to     eq('public-read')
        expect(hash_info[:form_data]["success_action_status"]).to eq('201')
      end
    end

    describe 'url for put' do
      context 'default ttl' do
        it 'return PUT url expires in 15m' do
          uri = URI(subject.presigned_put('file11', 'image/png'))

          expect(uri.scheme).to eq('https')
          expect(uri.host).to end_with('amazonaws.com')
          expect(uri.path).to eq('/file11')
          expect(uri.query).to include('X-Amz-Expires=900')
          expect(uri.query).to include('x-amz-acl=public-read')
        end
      end

      context 'ttl is 1 day' do
        it 'return PUT url expires in 1d' do
          uri = URI(subject.presigned_put('file11', 'image/png', 24*60*60))

          expect(uri.scheme).to eq('https')
          expect(uri.host).to end_with('amazonaws.com')
          expect(uri.path).to eq('/file11')
          expect(uri.query).to include('X-Amz-Expires=86400')
          expect(uri.query).to include('x-amz-acl=public-read')
        end
      end
    end

    describe 'public url' do
      it 'return GET url' do
        expect(subject.url('file12')).to start_with('https://')
        expect(subject.url('file12')).to end_with('/file12')
      end
    end
  end

  context 'custom bucket' do
    subject { described_class.new('__BUCKET_NAME__') }

    describe 'url for form post' do
      it 'return hash info' do
        hash_info = subject.presigned_post('file2')

        expect(hash_info).to be
        expect(hash_info[:url]).to    start_with('https://')
        expect(hash_info[:host]).to   be
        expect(hash_info[:bucket]).to eq('__BUCKET_NAME__')

        expect(hash_info[:form_data]["policy"]).to  be
        expect(hash_info[:form_data]["key"]).to     eq('file2')
        expect(hash_info[:form_data]["acl"]).to     eq('public-read')
        expect(hash_info[:form_data]["success_action_status"]).to eq('201')
      end
    end

    describe 'url for put' do
      context 'default ttl' do
        it 'return PUT url expires in 15m' do
          uri = URI(subject.presigned_put('file21', 'image/png'))

          expect(uri.scheme).to eq('https')
          expect(uri.host).to end_with('amazonaws.com')
          expect(uri.path).to eq('/__BUCKET_NAME__/file21')
          expect(uri.query).to include('X-Amz-Expires=900')
          expect(uri.query).to include('x-amz-acl=public-read')
        end
      end

      context 'ttl is 1 day' do
        it 'return PUT url expires in 1d' do
          uri = URI(subject.presigned_put('file21', 'image/png', 24*60*60))
          expect(uri.scheme).to eq('https')
          expect(uri.host).to end_with('amazonaws.com')
          expect(uri.path).to eq('/__BUCKET_NAME__/file21')
          expect(uri.query).to include('X-Amz-Expires=86400')
          expect(uri.query).to include('x-amz-acl=public-read')
        end
      end
    end

    describe 'public url' do
      it 'return GET url' do
        expect(subject.url('file22')).to start_with('https://')
        expect(subject.url('file22')).to end_with('/__BUCKET_NAME__/file22')
      end
    end
  end

  context 'mask key enabled' do
    before do
      TpCommon::FileStorage.configure do|configuration|
        configuration.aws_key_id      = access_key_id
        configuration.aws_secret_key  = secret_access_key
        configuration.default_bucket  = default_bucket
        configuration.key_prefix = 'testuser'
      end
    end

    context 'default bucket' do
      subject { described_class.new }

      describe 'url for form post' do
        it 'return hash info with key/file with prefix' do
          hash_info = subject.presigned_post('file1')

          expect(hash_info).to be
          expect(hash_info[:url]).to    start_with('https://')
          expect(hash_info[:host]).to   be
          expect(hash_info[:bucket]).to be # eq(DEFAULT_BUCKET_NAME)

          expect(hash_info[:form_data]["policy"]).to  be
          expect(hash_info[:form_data]["key"]).to     eq('testuser/file1')
          expect(hash_info[:form_data]["acl"]).to     eq('public-read')
          expect(hash_info[:form_data]["success_action_status"]).to eq('201')
        end
      end

      describe 'url for put' do
        context 'default ttl' do
          it 'return PUT url expires in 15m with key/file with prefix' do
            uri = URI(subject.presigned_put('file11', 'image/png'))

            expect(uri.scheme).to eq('https')
            expect(uri.host).to end_with('amazonaws.com')
            expect(uri.path).to eq('/testuser/file11')
            expect(uri.query).to include('X-Amz-Expires=900')
            expect(uri.query).to include('x-amz-acl=public-read')
          end
        end

        context 'ttl is 1 day' do
          it 'return PUT url expires in 1d with key/file with prefix' do
            uri = URI(subject.presigned_put('file11', 'image/png', 24*60*60))

            expect(uri.scheme).to eq('https')
            expect(uri.host).to end_with('amazonaws.com')
            expect(uri.path).to eq('/testuser/file11')
            expect(uri.query).to include('X-Amz-Expires=86400')
            expect(uri.query).to include('x-amz-acl=public-read')
          end
        end
      end

      describe 'public url' do
        it 'return GET url with key/file with prefix' do
          expect(subject.url('file12')).to start_with('https://')
          expect(subject.url('file12')).to end_with('/testuser/file12')
        end
      end
    end

    context 'custom bucket' do
      subject { described_class.new('__BUCKET_NAME__') }

      describe 'url for form post' do
        it 'return hash info with key/file with prefix' do
          hash_info = subject.presigned_post('file2')

          expect(hash_info).to be
          expect(hash_info[:url]).to    start_with('https://')
          expect(hash_info[:host]).to   be
          expect(hash_info[:bucket]).to eq('__BUCKET_NAME__')

          expect(hash_info[:form_data]["policy"]).to  be
          expect(hash_info[:form_data]["key"]).to     eq('testuser/file2')
          expect(hash_info[:form_data]["acl"]).to     eq('public-read')
          expect(hash_info[:form_data]["success_action_status"]).to eq('201')
        end
      end

      describe 'url for put' do
        context 'default ttl' do
          it 'return PUT url expires in 15m with key/file with prefix' do
            uri = URI(subject.presigned_put('file21', 'image/png'))

            expect(uri.scheme).to eq('https')
            expect(uri.host).to end_with('amazonaws.com')
            expect(uri.path).to eq('/__BUCKET_NAME__/testuser/file21')
            expect(uri.query).to include('X-Amz-Expires=900')
            expect(uri.query).to include('x-amz-acl=public-read')
          end
        end

        context 'ttl is 1 day' do
          it 'return PUT url expires in 1d with key/file with prefix' do
            uri = URI(subject.presigned_put('file21', 'image/png', 24*60*60))
            expect(uri.scheme).to eq('https')
            expect(uri.host).to end_with('amazonaws.com')
            expect(uri.path).to eq('/__BUCKET_NAME__/testuser/file21')
            expect(uri.query).to include('X-Amz-Expires=86400')
            expect(uri.query).to include('x-amz-acl=public-read')
          end
        end
      end

      describe 'public url' do
        it 'return GET url with key/file with prefix' do
          expect(subject.url('file22')).to start_with('https://')
          expect(subject.url('file22')).to end_with('/__BUCKET_NAME__/testuser/file22')
        end
      end
    end
  end
end
