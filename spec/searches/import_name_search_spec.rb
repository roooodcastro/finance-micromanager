# frozen_string_literal: true

RSpec.describe ImportNameSearch, type: :search do
  describe '.search' do
    subject(:search_results) { described_class.new(relation, query_params).search }

    let(:relation) { ImportName.all }
    let(:query_params) { {} }

    context 'when a custom relation is passed to the class' do
      let(:relation) { ImportName.where(profile:) }
      let(:profile) { create(:profile) }
      let!(:import_name_a) { create(:import_name, profile:) }

      before { create(:import_name) }

      it { is_expected.to contain_exactly(import_name_a) }
    end

    context 'when search_string is specified' do
      let(:query_params) { { search_string: } }

      let!(:found_import_name_a) { create(:import_name, import_name: 'THIS THAT') }
      let!(:found_import_name_b) { create(:import_name, transaction_name: 'TrAnSlAtEd to That') }
      let!(:not_found_import_name) { create(:import_name) }

      context 'and it is blank' do
        let(:search_string) { '' }

        it { is_expected.to contain_exactly(found_import_name_a, found_import_name_b, not_found_import_name) }
      end

      context 'and it is present' do
        let(:search_string) { 'that' }

        it { is_expected.to contain_exactly(found_import_name_a, found_import_name_b) }
      end
    end
  end
end
