require 'spec_helper'

RSpec.describe TpCommon::FileStorage::Downloaders::Private do
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
      conn.directories.get(default_bucket).files.create(key: 'file1', body: 'file1')
    end
    subject { described_class.new }

    context 'file not found' do
      describe '#download' do
        it 'raise FileNotFound error' do
          expect{ subject.download('file2') }.to raise_error(TpCommon::FileStorage::Errors::FileNotFound)
        end
      end

      describe '#read' do
        it 'raise FileNotFound error' do
          expect{ subject.read('file2') }.to raise_error(TpCommon::FileStorage::Errors::FileNotFound)
        end
      end
    end

    context 'file exists' do

      describe '#download' do
        it 'return file object' do
          expect(subject.download('file1')).to be
          expect(subject.download('file1').body).to eq('file1')
        end
      end

      describe '#read' do
        it 'return file content' do
          expect(subject.read('file1')).to eq('file1')
        end
      end

      # context 'fail once' do
      #   describe '#download' do
      #     it 'return file object'
      #   end

      #   describe '#read' do
      #     it 'return file content'
      #   end
      # end

      # context 'fail twice' do
      #   describe '#download' do
      #     it 'return file object'
      #   end

      #   describe '#read' do
      #     it 'return file content'
      #   end
      # end

      # context 'fail triple' do
      #   it 'raise FailedToDownload error'
      # end
    end
  end

  context 'custom bucket' do
    before do
      conn.directories.create(key: '__custom_bucket__')
      conn.directories.get('__custom_bucket__').files.create(key: 'file1', body: 'file1')
    end
    subject { described_class.new('__custom_bucket__') }

    context 'file not found' do
      describe '#download' do
        it 'raise FileNotFound error' do
          expect{ subject.download('file2') }.to raise_error(TpCommon::FileStorage::Errors::FileNotFound)
        end
      end

      describe '#read' do
        it 'raise FileNotFound error' do
          expect{ subject.read('file2') }.to raise_error(TpCommon::FileStorage::Errors::FileNotFound)
        end
      end
    end

    context 'file exists' do

      describe '#download' do
        it 'return file object' do
          expect(subject.download('file1')).to be
          expect(subject.download('file1').body).to eq('file1')
        end
      end

      describe '#read' do
        it 'return file content' do
          expect(subject.read('file1')).to eq('file1')
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
        conn.directories.get(default_bucket).files.create(key: 'testuser/file1', body: 'file1-with-prefix')
        conn.directories.get(default_bucket).files.create(key: 'file2', body: 'file2')
      end
      subject { described_class.new }

      context 'file not found' do
        describe '#download' do
          it 'raise FileNotFound error with key/file with prefix' do
            expect{ subject.download('file2') }.to raise_error(TpCommon::FileStorage::Errors::FileNotFound)
          end
        end

        describe '#read' do
          it 'raise FileNotFound error with key/file with prefix' do
            expect{ subject.read('file2') }.to raise_error(TpCommon::FileStorage::Errors::FileNotFound)
          end
        end
      end

      context 'file exists' do

        describe '#download' do
          it 'return file object with key/file with prefix' do
            expect(subject.download('file1')).to be

            expect(subject.download('file1').body).to eq('file1-with-prefix')
          end
        end

        describe '#read' do
          it 'return file content with key/file with prefix' do
            expect(subject.read('file1')).to eq('file1-with-prefix')
          end
        end

        # context 'fail once' do
        #   describe '#download' do
        #     it 'return file object'
        #   end

        #   describe '#read' do
        #     it 'return file content'
        #   end
        # end

        # context 'fail twice' do
        #   describe '#download' do
        #     it 'return file object'
        #   end

        #   describe '#read' do
        #     it 'return file content'
        #   end
        # end

        # context 'fail triple' do
        #   it 'raise FailedToDownload error'
        # end
      end
    end

    context 'custom bucket' do
      before do
        conn.directories.create(key: '__custom_bucket__')
        conn.directories.get('__custom_bucket__').files.create(key: 'testuser/file1', body: 'file1-with-prefix')
        conn.directories.get('__custom_bucket__').files.create(key: 'file2', body: 'file2')
      end
      subject { described_class.new('__custom_bucket__') }

      context 'file not found' do
        describe '#download' do
          it 'raise FileNotFound error with key/file with prefix' do
            expect{ subject.download('file2') }.to raise_error(TpCommon::FileStorage::Errors::FileNotFound)
          end
        end

        describe '#read' do
          it 'raise FileNotFound error with key/file with prefix' do
            expect{ subject.read('file2') }.to raise_error(TpCommon::FileStorage::Errors::FileNotFound)
          end
        end
      end

      context 'file exists' do

        describe '#download' do
          it 'return file object with key/file with prefix' do
            expect(subject.download('file1')).to be

            expect(subject.download('file1').body).to eq('file1-with-prefix')
          end
        end

        describe '#read' do
          it 'return file content with key/file with prefix' do
            expect(subject.read('file1')).to eq('file1-with-prefix')
          end
        end
      end
    end
  end
end
