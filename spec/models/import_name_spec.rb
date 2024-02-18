# frozen_string_literal: true

RSpec.describe ImportName do
  subject { import_name }

  let(:import_name) { build(:import_name) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end

  describe '.as_json' do
    subject { import_name.as_json }

    let(:import_name) { create(:import_name, import_name: 'import', transaction_name: 'transaction') }
    let(:expected_json) do
      { id: import_name.id, import_name: 'import', transaction_name: 'transaction', profile_id: import_name.profile_id }
    end

    it { is_expected.to eq(expected_json.stringify_keys) }
  end
end
