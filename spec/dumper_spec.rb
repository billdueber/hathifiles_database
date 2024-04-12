# frozen_string_literal: true

require "tempfile"
require "tmpdir"
require_relative "../lib/hathifiles_database/dumper"

RSpec.describe HathifilesDatabase::Dumper do
  let(:conn) { HathifilesDatabase.new(ENV["HATHIFILES_MYSQL_CONNECTION"]) }
  let(:dumper) { described_class.new(conn) }
  let(:all_tables) { [HathifilesDatabase::Constants::MAINTABLE] + HathifilesDatabase::Constants::FOREIGN_TABLES.values }
  let(:txt_datafile_path) { data_file_path "sample_10.txt" }

  before(:each) do
    all_tables.each do |table|
      conn.rawdb[table].delete
    end
  end

  describe "#dump" do
    it "dumps the expected number of records" do
      conn.update_from_file(txt_datafile_path)
      Dir.mktmpdir do |tmpdir|
        dump_file = File.join(tmpdir, "dump.txt")
        dumper.dump(output_file: dump_file)
        expect(File.readlines(dump_file, chomp: true).count).to eq 10
      end
    end
  end

  describe "#dump_from_file" do
    it "dumps the expected number of records" do
      Dir.mktmpdir do |tmpdir|
        dump_file = dumper.dump_from_file(hathifile: txt_datafile_path, output_directory: tmpdir)[:hf]
        expect(File.readlines(dump_file, chomp: true).count).to eq 10
      end
    end

    it "dumps the same data as #dump" do
      conn.update_from_file(txt_datafile_path)
      Dir.mktmpdir do |tmpdir|
        dump_file_1 = dumper.dump_from_file(hathifile: txt_datafile_path, output_directory: tmpdir)[:hf]
        dump_file_2 = File.join(tmpdir, "dump.txt")
        dumper.dump(output_file: dump_file_2)
        expect(File.readlines(dump_file_1, chomp: true).sort).to eq(
          File.readlines(dump_file_2, chomp: true).sort
        )
      end
    end
  end
end
