require 'spec_helper'

RSpec.describe TpCommon::FileStorage::Uploaders::Public do
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
    before do
      conn.directories.create(key: default_bucket)
    end
    subject { described_class.new }

    context 'file doesnt exists' do
      describe '#upload' do
        it 'uploads success' do
          expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be_nil

          expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('file1.txt')

          expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be
          expect(conn.directories.get(default_bucket).files.get('file1.txt').body).to eq('__file1_content__')
          expect(conn.directories.get(default_bucket).files.get('file1.txt').public_url).to be
        end
      end

      describe '#url' do
        it 'return nil' do
          expect(subject.url('file1.txt')).to be_nil
        end
      end
    end

    context 'file exist' do
      before do
        conn.directories.get(default_bucket).files.create(key: 'file1.txt', body: '__file1_old_content__', public: true)
      end

      describe '#upload' do
        it 'uploads success' do
          expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be

          expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('file1.txt')

          expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be
          expect(conn.directories.get(default_bucket).files.get('file1.txt').body).to eq('__file1_content__')
          expect(conn.directories.get(default_bucket).files.get('file1.txt').public_url).to be
        end
      end

      describe '#url' do
        it 'return public url' do
          expect(subject.url('file1.txt')).to start_with('https://')
          expect(subject.url('file1.txt')).not_to include('X-Amz-Expires=')
        end
      end
    end
  end

  context 'custom bucket' do
    before do
      conn.directories.create(key: 'custom-bucket')
    end
    subject { described_class.new('custom-bucket') }

    context 'file doesnt exists' do
      describe '#upload' do
        it 'uploads success' do
          expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be_nil

          expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('file1.txt')

          expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be
          expect(conn.directories.get('custom-bucket').files.get('file1.txt').body).to eq('__file1_content__')
          expect(conn.directories.get('custom-bucket').files.get('file1.txt').public_url).to be
        end
      end

      describe '#url' do
        it 'return nil' do
          expect(subject.url('file1.txt')).to be_nil
        end
      end
    end

    context 'file exist' do
      before do
        conn.directories.get('custom-bucket').files.create(key: 'file1.txt', body: '__file1_old_content__', public: true)
      end

      describe '#upload' do
        it 'uploads success' do
          expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be

          expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('file1.txt')

          expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be
          expect(conn.directories.get('custom-bucket').files.get('file1.txt').body).to eq('__file1_content__')
          expect(conn.directories.get('custom-bucket').files.get('file1.txt').public_url).to be
        end
      end

      describe '#url' do
        it 'return public url' do
          expect(subject.url('file1.txt')).to start_with('https://')
          expect(subject.url('file1.txt')).to include('custom-bucket')
          expect(subject.url('file1.txt')).not_to include('X-Amz-Expires=')
        end
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
      before do
        conn.directories.create(key: default_bucket)
      end
      subject { described_class.new }

      context 'file doesnt exists' do
        describe '#upload' do
          it 'uploads success and return key with prefix' do
            expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be_nil
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt')).to be_nil

            expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('testuser/file1.txt')

            expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be_nil
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt')).to be
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt').body).to eq('__file1_content__')
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt').public_url).to be
          end
        end

        describe '#url' do
          it 'return nil' do
            expect(subject.url('testuser/file1.txt')).to be_nil
          end
        end
      end

      context 'file exist' do
        before do
          conn.directories.get(default_bucket).files.create(key: 'file1.txt', body: '__file1_old_content__', public: true)
          conn.directories.get(default_bucket).files.create(key: 'testuser/file1.txt', body: '__file1_old_content_with_prefix__', public: true)
        end

        describe '#upload' do
          it 'uploads success and return key with prefix' do
            expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt')).to be

            expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('testuser/file1.txt')

            expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt')).to be
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt').body).to eq('__file1_content__')
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt').public_url).to be
          end
        end

        describe '#url' do
          it 'return public url with prefix' do
            expect(subject.url('testuser/file1.txt')).to start_with('https://')
            expect(subject.url('testuser/file1.txt')).not_to include('X-Amz-Expires=')

            expect(subject.url('testuser/file1.txt')).to include('testuser/file1.txt')
          end
        end
      end
    end

    context 'custom bucket' do
      before do
        conn.directories.create(key: 'custom-bucket')
      end
      subject { described_class.new('custom-bucket') }

      context 'file doesnt exists' do
        describe '#upload' do
          it 'uploads success and return key with prefix' do
            expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be_nil
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt')).to be_nil

            expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('testuser/file1.txt')

            expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be_nil
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt')).to be
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt').body).to eq('__file1_content__')
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt').public_url).to be
          end
        end

        describe '#url' do
          it 'return nil' do
            expect(subject.url('file1.txt')).to be_nil
          end
        end
      end

      context 'file exist' do
        before do
          conn.directories.get('custom-bucket').files.create(key: 'file1.txt', body: '__file1_old_content__', public: true)
          conn.directories.get('custom-bucket').files.create(key: 'testuser/file1.txt', body: '__file1_old_content_with_prefix__', public: true)
        end

        describe '#upload' do
          it 'uploads success and return key with prefix' do
            expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt')).to be

            expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('testuser/file1.txt')

            expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt')).to be
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt').body).to eq('__file1_content__')
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt').public_url).to be
          end
        end

        describe '#url' do
          it 'return public url with prefix' do
            expect(subject.url('file1.txt')).to start_with('https://')
            expect(subject.url('file1.txt')).to include('custom-bucket')
            expect(subject.url('file1.txt')).not_to include('X-Amz-Expires=')

            expect(subject.url('testuser/file1.txt')).to include('testuser/file1.txt')
          end
        end
      end
    end
  end
end
