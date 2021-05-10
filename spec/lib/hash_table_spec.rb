require 'spec_helper'
require 'hash_table'

RSpec.describe HashTable do
  subject(:hash_table) { described_class.new }

  describe "#[key]" do
    it "returns value associated with key" do
      hash_table['key'] = 10
      expect(hash_table['key']).to eq(10)
    end
  end
end
