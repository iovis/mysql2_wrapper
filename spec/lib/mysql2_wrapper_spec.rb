require 'spec_helper'

describe Mysql2Wrapper::Db do
  let(:db) { build(:db) }

  it 'has a valid connection' do
    expect(db.connected?).to be_truthy
  end

  let(:name)  { 'foobar' }
  let(:name2) { 'foobar2' }
  let(:name3) { 'foobar3' }

  before :example do
    db.query <<-SQL
      CREATE TABLE test (
        id  tinyint(4) NOT NULL AUTO_INCREMENT,
        name varchar(32) NOT NULL,
        PRIMARY KEY (id)
      );
    SQL

    db.query 'INSERT INTO test (name) VALUES (?), (?), (?);', name, name2, name3
  end

  context '#query' do
    it 'should return a symbolized hash' do
      result = db.query('select name from test;').first[:name]
      expect(result).to eq name
    end

    it 'should admit prepared statements' do
      result = db.query('select name from test where name = ?;', name).first[:name]
      expect(result).to eq name
    end
  end

  context '#get_one' do
    it 'should return one value' do
      result = db.get_one 'select * from test where name = ?;', name
      expect(result).to be_a Hash
      expect(result.size).to eq 2 # Two columns
    end

    it 'should return one value even if there are more' do
      result = db.get_one "select * from test where name like '#{name}%';"
      expect(result).to be_a Hash
      expect(result.size).to eq 2 # Two columns
    end

    it 'should return nil if there are no results' do
      result = db.get_one 'select * from test where name is null;'
      expect(result).to be_nil
    end
  end

  context '#get_one!' do
    it 'should return one value' do
      result = db.get_one! 'select * from test where name = ?;', name
      expect(result).to be_a Hash
      expect(result.size).to eq 2 # Two columns
    end

    it 'should fail if there is more than one record' do
      expect { db.get_one! "select * from test where name like '#{name}%';" }.to raise_error RuntimeError
    end

    it 'should fail if there are no results' do
      expect { db.get_one! 'select * from test where name is null;' }.to raise_error RuntimeError
    end
  end

  context '#get_all' do
    it 'should return a list of all matches' do
      results = db.get_all 'select * from test;'
      expect(results).to be_a Array
      expect(results.size).to eq 3
    end

    it 'should return an empty list if there are no results' do
      results = db.get_all 'select * from test where name is null;'
      expect(results).to be_empty
    end
  end

  context '#count' do
    it 'should return an integer with the result' do
      expect(db.count('select count(*) from test;')).to eq 3
    end

    it 'should fail if there is no count' do
      expect { db.count 'select * from test;' }.to raise_error ArgumentError
    end
  end

  context '#transaction' do
    it 'should fail without a block' do
      expect { db.transaction 'select * from test;' }.to raise_error ArgumentError
    end

    it 'should do what a transaction does' do
      db.transaction do
        100.times { |i| db.query 'INSERT INTO test (name) VALUES (?);', "#{name}#{i}" }
      end

      expect(db.count('select count(*) from test;')).to eq 103
    end

    it 'should rollback if there is an error' do
      db.transaction do
        100.times { |i| db.query 'INSERT INTO test (name) VALUES (?);', "#{name}#{i}" }
        db.query 'INSERT INTO fake_table VALUES (12);'
      end

      expect(db.count('select count(*) from test;')).to eq 3
    end
  end

  after :example do
    db.query 'DROP TABLE test;'
  end
end
