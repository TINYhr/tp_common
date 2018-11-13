require 'spec_helper'

RSpec.describe TpCommon::FileStorage::Cleaners::Cleaner do
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

  context 'delete in default bucket' do
    before do
      conn.directories.create(key: default_bucket)
      conn.directories.get(default_bucket).files.create(key: 'file1', body: 'file1')
      conn.directories.get(default_bucket).files.create(key: 'file2', body: 'file2')
    end

    it 'delete file in bucket' do
      expect(conn.directories.get(default_bucket).files.get('file1')).not_to be_nil
      expect(conn.directories.get(default_bucket).files.get('file2')).not_to be_nil

      described_class.new.clean(['file1', 'file2'])

      expect(conn.directories.get(default_bucket).files.get('file1')).to be_nil
      expect(conn.directories.get(default_bucket).files.get('file2')).to be_nil
    end
  end

  context 'delete in custom bucket' do
    before do
      conn.directories.create(key: '__BUCKET_NAME__')
      conn.directories.get('__BUCKET_NAME__').files.create(key: 'file1', body: 'file1')
      conn.directories.get('__BUCKET_NAME__').files.create(key: 'file2', body: 'file2')
    end

    it 'delete file in bucket' do
      expect(conn.directories.get('__BUCKET_NAME__').files.get('file1')).not_to be_nil
      expect(conn.directories.get('__BUCKET_NAME__').files.get('file2')).not_to be_nil

      described_class.new('__BUCKET_NAME__').clean(['file1', 'file2'])

      expect(conn.directories.get('__BUCKET_NAME__').files.get('file1')).to be_nil
      expect(conn.directories.get('__BUCKET_NAME__').files.get('file2')).to be_nil
    end
  end

  context 'mask key enabled' do
    before do
      TpCommon::FileStorage.configure do|configuration|
        configuration.aws_key_id      = access_key_id
        configuration.aws_secret_key  = secret_access_key
        configuration.key_prefix = 'testuser'
        configuration.default_bucket  = default_bucket
      end
    end

    context 'delete in default bucket' do
      before do
        conn.directories.create(key: default_bucket)
        conn.directories.get(default_bucket).files.create(key: 'file1', body: 'file1')
        conn.directories.get(default_bucket).files.create(key: 'testuser/file1', body: 'file1')
        conn.directories.get(default_bucket).files.create(key: 'file2', body: 'file2')
        conn.directories.get(default_bucket).files.create(key: 'testuser/file2', body: 'file2')
      end

      it 'delete file in bucket which have configured prefix' do
        expect(conn.directories.get(default_bucket).files.get('file1')).not_to          be_nil
        expect(conn.directories.get(default_bucket).files.get('testuser/file1')).not_to be_nil
        expect(conn.directories.get(default_bucket).files.get('file2')).not_to          be_nil
        expect(conn.directories.get(default_bucket).files.get('testuser/file2')).not_to be_nil

        described_class.new.clean(['file1', 'file2'])

        expect(conn.directories.get(default_bucket).files.get('file1')).not_to      be_nil
        expect(conn.directories.get(default_bucket).files.get('testuser/file1')).to be_nil
        expect(conn.directories.get(default_bucket).files.get('file2')).not_to      be_nil
        expect(conn.directories.get(default_bucket).files.get('testuser/file2')).to be_nil
      end
    end

    context 'delete in custom bucket' do
      before do
        conn.directories.create(key: '__BUCKET_NAME__')
        conn.directories.get('__BUCKET_NAME__').files.create(key: 'file1', body: 'file1')
        conn.directories.get('__BUCKET_NAME__').files.create(key: 'testuser/file1', body: 'file1')
        conn.directories.get('__BUCKET_NAME__').files.create(key: 'file2', body: 'file2')
        conn.directories.get('__BUCKET_NAME__').files.create(key: 'testuser/file2', body: 'file2')
      end

      it 'delete file in bucket which have configured prefix' do
        expect(conn.directories.get('__BUCKET_NAME__').files.get('file1')).not_to           be_nil
        expect(conn.directories.get('__BUCKET_NAME__').files.get('testuser/file1')).not_to  be_nil
        expect(conn.directories.get('__BUCKET_NAME__').files.get('file2')).not_to           be_nil
        expect(conn.directories.get('__BUCKET_NAME__').files.get('testuser/file2')).not_to  be_nil

        described_class.new('__BUCKET_NAME__').clean(['file1', 'file2'])

        expect(conn.directories.get('__BUCKET_NAME__').files.get('file1')).not_to       be_nil
        expect(conn.directories.get('__BUCKET_NAME__').files.get('testuser/file1')).to  be_nil
        expect(conn.directories.get('__BUCKET_NAME__').files.get('file2')).not_to       be_nil
        expect(conn.directories.get('__BUCKET_NAME__').files.get('testuser/file2')).to  be_nil
      end
    end
  end
end
