# frozen_string_literal: true

RSpec.describe TransactionSearch, type: :search do
  describe '.search' do
    subject(:search_results) { described_class.new(relation, query_params).search }

    let(:relation) { Transaction.all }
    let(:query_params) { {} }

    context 'when a custom relation is passed to the class' do
      let(:relation) { Transaction.where(category:) }
      let(:category) { create(:category) }
      let!(:transaction_a) { create(:transaction, category:) }

      before { create(:transaction) }

      it { is_expected.to contain_exactly(transaction_a) }
    end

    context 'when search_string is specified' do
      let(:query_params) { { search_string: } }

      let!(:found_transaction) { create(:transaction, name: 'Super') }
      let!(:not_found_transaction) { create(:transaction, name: 'Other') }

      context 'and it is blank' do
        let(:search_string) { '' }

        it { is_expected.to contain_exactly(found_transaction, not_found_transaction) }
      end

      context 'and it is present' do
        let(:search_string) { 'Su' }

        it { is_expected.to contain_exactly(found_transaction) }
      end
    end

    context 'when days_to_show is specified' do
      let(:query_params) { { days_to_show: } }

      let!(:newer_transaction) { create(:transaction, transaction_date: 14.days.ago) }
      let!(:older_transaction) { create(:transaction, transaction_date: 15.days.ago) }

      context 'and it is blank' do
        let(:days_to_show) { '' }

        it { is_expected.to contain_exactly(newer_transaction, older_transaction) }
      end

      context 'and it is an invalid number' do
        let(:days_to_show) { 'ABC' }

        it { is_expected.to contain_exactly(newer_transaction, older_transaction) }
      end

      context 'and it is a valid number' do
        let(:days_to_show) { '14' }

        it { is_expected.to contain_exactly(newer_transaction) }
      end
    end

    context 'when exclude_debits is specified' do
      let(:query_params) { { exclude_debits: } }
      let!(:money_in_transaction) { create(:transaction, amount: 10) }
      let!(:spend_transaction) { create(:transaction, amount: -10) }

      context 'and it is false' do
        let(:exclude_debits) { false }

        it { is_expected.to contain_exactly(money_in_transaction, spend_transaction) }
      end

      context 'and it is true' do
        let(:exclude_debits) { true }

        it { is_expected.to contain_exactly(money_in_transaction) }
      end
    end

    context 'when exclude_credits is specified' do
      let(:query_params) { { exclude_credits: } }
      let!(:money_in_transaction) { create(:transaction, amount: 10) }
      let!(:spend_transaction) { create(:transaction, amount: -10) }

      context 'and it is false' do
        let(:exclude_credits) { false }

        it { is_expected.to contain_exactly(money_in_transaction, spend_transaction) }
      end

      context 'and it is true' do
        let(:exclude_credits) { true }

        it { is_expected.to contain_exactly(spend_transaction) }
      end
    end

    context 'when start_date is specified' do
      let(:query_params) { { start_date: } }
      let(:start_date) { 2.days.ago }

      let!(:old_transaction) { create(:transaction, transaction_date: 3.days.ago) }
      let!(:limit_transaction) { create(:transaction, transaction_date: 2.days.ago) }
      let!(:new_transaction) { create(:transaction, transaction_date: 1.day.ago) }

      it { is_expected.to contain_exactly(limit_transaction, new_transaction) }
      it { is_expected.not_to include(old_transaction) }
    end

    context 'when end_date is specified' do
      let(:query_params) { { end_date: } }
      let(:end_date) { 2.days.ago }

      let!(:old_transaction) { create(:transaction, transaction_date: 3.days.ago) }
      let!(:limit_transaction) { create(:transaction, transaction_date: 2.days.ago) }
      let!(:new_transaction) { create(:transaction, transaction_date: 1.day.ago) }

      it { is_expected.to contain_exactly(old_transaction, limit_transaction) }
      it { is_expected.not_to include(new_transaction) }
    end

    context 'when both start and end dates are specified' do
      let(:query_params) { { start_date:, end_date: } }
      let(:start_date) { 2.days.ago }
      let(:end_date) { 1.day.ago }

      let!(:old_transaction) { create(:transaction, transaction_date: 3.days.ago) }
      let!(:start_limit_transaction) { create(:transaction, transaction_date: 2.days.ago) }
      let!(:end_limit_transaction) { create(:transaction, transaction_date: 1.day.ago) }
      let!(:new_transaction) { create(:transaction, transaction_date: Date.current) }

      it { is_expected.to contain_exactly(start_limit_transaction, end_limit_transaction) }
      it { is_expected.not_to include(old_transaction, new_transaction) }
    end

    context 'when category_ids is specified' do
      let(:query_params) { { category_ids: } }

      let(:category_a) { create(:category) }
      let(:category_b) { create(:category) }
      let(:subcategory_a) { create(:subcategory, category: category_a) }
      let(:subcategory_b) { create(:subcategory, category: category_a) }

      let!(:cat_a_transaction) { create(:transaction, category: category_a) }
      let!(:cat_b_transaction) { create(:transaction, category: category_b) }
      let!(:subcat_a_transaction) { create(:transaction, category: category_a, subcategory: subcategory_a) }
      let!(:subcat_b_transaction) { create(:transaction, category: category_a, subcategory: subcategory_b) }

      context 'and it is empty' do
        let(:category_ids) { '' }

        it 'returns all transactions' do
          expect(search_results).to contain_exactly(
            cat_a_transaction,
            cat_b_transaction,
            subcat_a_transaction,
            subcat_b_transaction
          )
        end
      end

      context 'and it contains only category_ids' do
        let(:category_ids) { category_a.id }

        it { is_expected.to contain_exactly(cat_a_transaction, subcat_a_transaction, subcat_b_transaction) }
      end

      context 'and it contains only subcategory_ids' do
        let(:category_ids) { "#{category_a.id}|#{subcategory_a.id}" }

        it { is_expected.to contain_exactly(subcat_a_transaction) }
      end

      context 'and it contains a mix between category_ids and subcategory_ids' do
        let(:category_ids) { [category_b.id, "#{category_a.id}|#{subcategory_a.id}"].join(',') }

        it { is_expected.to contain_exactly(cat_b_transaction, subcat_a_transaction) }
      end
    end

    context 'when wallet_ids is specified' do
      let(:query_params) { { wallet_ids: } }

      let(:wallet_a) { create(:wallet) }
      let(:wallet_b) { create(:wallet) }

      let!(:transaction) { create(:transaction, wallet: nil) }
      let!(:wallet_a_transaction) { create(:transaction, wallet: wallet_a) }
      let!(:wallet_b_transaction) { create(:transaction, wallet: wallet_b) }

      context 'and it is empty' do
        let(:wallet_ids) { '' }

        it { is_expected.to contain_exactly(transaction, wallet_a_transaction, wallet_b_transaction) }
      end

      context 'and it contains only valid wallet_ids' do
        let(:wallet_ids) { [wallet_a.id, wallet_b.id].join(',') }

        it { is_expected.to contain_exactly(wallet_a_transaction, wallet_b_transaction) }
      end

      context 'and it contains only the null wallet_id' do
        let(:wallet_ids) { 'null' }

        it { is_expected.to contain_exactly(transaction) }
      end

      context 'and it contains a mix between valid and null wallet_ids' do
        let(:wallet_ids) { [wallet_b.id, 'null'].join(',') }

        it { is_expected.to contain_exactly(wallet_b_transaction, transaction) }
      end
    end

    context 'when transaction_automation_id is specified' do
      let(:query_params) { { transaction_automation_id: } }
      let(:transaction_automation_a) { create(:transaction_automation) }
      let(:transaction_automation_b) { create(:transaction_automation) }

      let!(:transaction_a) { create(:transaction) }
      let!(:transaction_b) { create(:transaction, transaction_automation: transaction_automation_a) }

      context 'and it is empty' do
        let(:transaction_automation_id) { nil }

        it { is_expected.to contain_exactly(transaction_a, transaction_b) }
      end

      context 'and it has an ID but there are no transactions from that automation' do
        let(:transaction_automation_id) { transaction_automation_b.id }

        it { is_expected.to be_empty }
      end

      context 'and it has an ID and there are transactions from that automation' do
        let(:transaction_automation_id) { transaction_automation_a.id }

        it { is_expected.to contain_exactly(transaction_b) }
      end
    end

    context 'when import_id is specified' do
      let(:query_params) { { import_id: } }
      let(:import1) { create(:import) }
      let(:import2) { create(:import) }

      let!(:transaction_a) { create(:transaction) }
      let!(:transaction_b) { create(:transaction, import: import1) }

      context 'and it is empty' do
        let(:import_id) { nil }

        it { is_expected.to contain_exactly(transaction_a, transaction_b) }
      end

      context 'and it has an ID but there are no transactions from that import' do
        let(:import_id) { import2.id }

        it { is_expected.to be_empty }
      end

      context 'and it has an ID and there are transactions from that import' do
        let(:import_id) { import1.id }

        it { is_expected.to contain_exactly(transaction_b) }
      end
    end

    context 'when sort_direction is specified' do
      let(:query_params) { { sort_direction: } }
      let!(:transaction_a) { create(:transaction, transaction_date: 2.days.ago) }
      let!(:transaction_b) { create(:transaction, transaction_date: 1.day.ago) }

      context 'and it is an invalid value' do
        let(:sort_direction) { 'iNvAlID' }

        it { is_expected.to eq([transaction_b, transaction_a]) }
      end

      context 'and it is ASC' do
        let(:sort_direction) { 'ASC' }

        it { is_expected.to eq([transaction_a, transaction_b]) }
      end

      context 'and it is asc' do
        let(:sort_direction) { 'asc' }

        it { is_expected.to eq([transaction_a, transaction_b]) }
      end

      context 'and it is desc' do
        let(:sort_direction) { 'desc' }

        it { is_expected.to eq([transaction_b, transaction_a]) }
      end
    end
  end
end
