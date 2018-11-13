require 'spec_helper'

RSpec.describe TpCommon::FileStorage::Uploaders::Private do
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
          expect(conn.directories.get(default_bucket).files.get('file1.txt').public_url).to be_nil
        end
      end

      describe '#url' do
        it 'return singed url with 1w = 604800s ttl' do
          expect(subject.url('file1.txt')).to start_with('https://')
          expect(subject.url('file1.txt')).to include('X-Amz-Expires=604800')
        end

        context 'custom ttl to 1d' do
          it 'return signed url with 1d = 86400s ttl' do
            expect(subject.url('file1.txt', 1.day.from_now)).to start_with('https://')
            expect(subject.url('file1.txt', 1.day.from_now)).to include('X-Amz-Expires=86400')
          end
        end
      end
    end

    context 'file exist' do
      before do
        conn.directories.get(default_bucket).files.create(key: 'file1.txt', body: '__file1_old_content__')
      end

      describe '#upload' do
        it 'uploads success' do
          expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be

          expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('file1.txt')

          expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be
          expect(conn.directories.get(default_bucket).files.get('file1.txt').body).to eq('__file1_content__')
          expect(conn.directories.get(default_bucket).files.get('file1.txt').public_url).to be_nil
        end
      end

      describe '#url' do
        it 'return singed url with 1w = 604800s ttl' do
          expect(subject.url('file1.txt')).to start_with('https://')
          expect(subject.url('file1.txt')).to include('X-Amz-Expires=604800')
        end

        context 'custom ttl to 1d' do
          it 'return signed url with 1d = 86400s ttl' do
            expect(subject.url('file1.txt', 1.day.from_now)).to start_with('https://')
            expect(subject.url('file1.txt', 1.day.from_now)).to include('X-Amz-Expires=86400')
          end
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
          expect(conn.directories.get('custom-bucket').files.get('file1.txt').public_url).to be_nil
        end
      end

      describe '#url' do
        it 'return signed url with 1w = 604800s ttl' do
          expect(subject.url('file1.txt')).to start_with('https://')
          expect(subject.url('file1.txt')).to include('custom-bucket')

          expect(subject.url('file1.txt')).to include('X-Amz-Expires=604800')
        end

        context 'custom ttl to 1d' do
          it 'return signed url with 1d = 86400s ttl' do
            expect(subject.url('file1.txt', 1.day.from_now)).to start_with('https://')
            expect(subject.url('file1.txt', 1.day.from_now)).to include('custom-bucket')

            expect(subject.url('file1.txt', 1.day.from_now)).to include('X-Amz-Expires=86400')
          end
        end
      end
    end

    context 'file exist' do
      before do
        conn.directories.get('custom-bucket').files.create(key: 'file1.txt', body: '__file1_old_content__')
      end

      describe '#upload' do
        it 'uploads success' do
          expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be

          expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('file1.txt')

          expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be
          expect(conn.directories.get('custom-bucket').files.get('file1.txt').body).to eq('__file1_content__')
          expect(conn.directories.get('custom-bucket').files.get('file1.txt').public_url).to be_nil
        end
      end

      describe '#url' do
        it 'return signed url with 1w = 604800s ttl' do
          expect(subject.url('file1.txt')).to start_with('https://')
          expect(subject.url('file1.txt')).to include('custom-bucket')

          expect(subject.url('file1.txt')).to include('X-Amz-Expires=604800')
        end

        context 'custom ttl to 1d' do
          it 'return signed url with 1d = 86400s ttl' do
            expect(subject.url('file1.txt', 1.day.from_now)).to start_with('https://')
            expect(subject.url('file1.txt', 1.day.from_now)).to include('custom-bucket')

            expect(subject.url('file1.txt', 1.day.from_now)).to include('X-Amz-Expires=86400')
          end
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
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt').public_url).to be_nil
          end
        end

        describe '#url' do
          context 'default ttl' do
            it 'return singed url with 1w = 604800s ttl' do
              expect(subject.url('file1.txt')).to start_with('https://')
              expect(subject.url('file1.txt')).to include('X-Amz-Expires=604800')
            end

            it 'return singed url with prefix' do
              expect(subject.url('file1.txt')).to include('testuser/file1.txt')
            end
          end

          context 'custom ttl to 1d' do
            it 'return signed url with 1d = 86400s ttl' do
              expect(subject.url('file1.txt', 1.day.from_now)).to start_with('https://')
              expect(subject.url('file1.txt', 1.day.from_now)).to include('X-Amz-Expires=86400')
            end

            it 'return signed url with prefix' do
              expect(subject.url('file1.txt', 1.day.from_now)).to include('testuser/file1.txt')
            end
          end
        end
      end

      context 'file exist' do
        before do
          conn.directories.get(default_bucket).files.create(key: 'file1.txt', body: '__file1_old_content__')
          conn.directories.get(default_bucket).files.create(key: 'testuser/file1.txt', body: '__file1_old_content_with_prefix__')
        end

        describe '#upload' do
          it 'uploads success and return key with prefix' do
            expect(conn.directories.get(default_bucket).files.get('file1.txt')).to be
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt')).to be

            expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('testuser/file1.txt')

            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt')).to be
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt').body).to eq('__file1_content__')
            expect(conn.directories.get(default_bucket).files.get('testuser/file1.txt').public_url).to be_nil
          end
        end

        describe '#url' do
          context 'default ttl' do
            it 'return singed url with 1w = 604800s ttl' do
              expect(subject.url('file1.txt')).to start_with('https://')
              expect(subject.url('file1.txt')).to include('X-Amz-Expires=604800')
            end

            it 'return singed url with prefix' do
              expect(subject.url('file1.txt')).to include('testuser/file1.txt')
            end
          end

          context 'custom ttl to 1d' do
            it 'return signed url with 1d = 86400s ttl' do
              expect(subject.url('file1.txt', 1.day.from_now)).to start_with('https://')
              expect(subject.url('file1.txt', 1.day.from_now)).to include('X-Amz-Expires=86400')
            end

            it 'return signed url with prefix' do
              expect(subject.url('file1.txt', 1.day.from_now)).to include('testuser/file1.txt')
            end
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
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt').public_url).to be_nil
          end
        end

        describe '#url' do
          context 'default ttl' do
            it 'return signed url with 1w = 604800s ttl' do
              expect(subject.url('file1.txt')).to start_with('https://')
              expect(subject.url('file1.txt')).to include('custom-bucket')

              expect(subject.url('file1.txt')).to include('X-Amz-Expires=604800')
            end

            it 'return signed url with prefix' do
              expect(subject.url('file1.txt')).to include('testuser/file1.txt')
            end
          end

          context 'custom ttl to 1d' do
            it 'return signed url with 1d = 86400s ttl' do
              expect(subject.url('file1.txt', 1.day.from_now)).to start_with('https://')
              expect(subject.url('file1.txt', 1.day.from_now)).to include('custom-bucket')

              expect(subject.url('file1.txt', 1.day.from_now)).to include('X-Amz-Expires=86400')
            end

            it 'return signed url with prefix' do
              expect(subject.url('file1.txt', 1.day.from_now)).to include('testuser/file1.txt')
            end
          end
        end
      end

      context 'file exist' do
        before do
          conn.directories.get('custom-bucket').files.create(key: 'file1.txt', body: '__file1_old_content__')
          conn.directories.get('custom-bucket').files.create(key: 'testuser/file1.txt', body: '__file1_old_content_with_prefix__')
        end

        describe '#upload' do
          it 'uploads success and return key with prefix' do
            expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt')).to be

            expect(subject.upload('file1.txt', '__file1_content__', 'text/plain')).to eq('testuser/file1.txt')

            expect(conn.directories.get('custom-bucket').files.get('file1.txt')).to be
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt')).to be
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt').body).to eq('__file1_content__')
            expect(conn.directories.get('custom-bucket').files.get('testuser/file1.txt').public_url).to be_nil
          end
        end

        describe '#url' do
          context 'default ttl' do
            it 'return signed url with 1w = 604800s ttl' do
              expect(subject.url('file1.txt')).to start_with('https://')
              expect(subject.url('file1.txt')).to include('custom-bucket')

              expect(subject.url('file1.txt')).to include('X-Amz-Expires=604800')
            end

            it 'return signed url with prefix' do
              expect(subject.url('file1.txt')).to include('testuser/file1.txt')
            end
          end

          context 'custom ttl to 1d' do
            it 'return signed url with 1d = 86400s ttl' do
              expect(subject.url('file1.txt', 1.day.from_now)).to start_with('https://')
              expect(subject.url('file1.txt', 1.day.from_now)).to include('custom-bucket')

              expect(subject.url('file1.txt', 1.day.from_now)).to include('X-Amz-Expires=86400')
            end

            it 'return signed url with prefix' do
              expect(subject.url('file1.txt', 1.day.from_now)).to include('testuser/file1.txt')
            end
          end
        end
      end
    end
  end
end
