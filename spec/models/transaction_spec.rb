# frozen_string_literal: true

RSpec.describe Transaction do
  let(:profile) { create(:profile) }

  describe 'validate reconciliation date' do
    subject(:errors) do
      transaction.valid?
      transaction.errors[:base]
    end

    before do
      create(:reconciliation, :finished, profile: profile, date: 2.days.ago)
      profile.reload
    end

    context 'when trying to create a transaction' do
      let(:transaction) { build(:transaction, profile:, transaction_date:) }

      context 'when the transaction date is after the reconciliation' do
        let(:transaction_date) { 1.day.ago }

        it { is_expected.to be_empty }
      end

      context 'when the transaction date is at or prior to the reconciliation' do
        let(:transaction_date) { 2.days.ago }

        it { is_expected.to be_present }
      end
    end

    context 'when trying to edit a transaction' do
      let(:transaction) do
        create(:transaction, :skip_validations, profile: profile, transaction_date: old_transaction_date,
               amount: old_amount)
      end

      let(:old_amount) { 10 }
      let(:new_amount) { 10 }

      before { transaction.update(transaction_date: new_transaction_date, amount: new_amount) }

      context 'when the transaction date is unchanged and after the reconciliation' do
        let(:old_transaction_date) { 1.day.ago }
        let(:new_transaction_date) { 1.day.ago }
        let(:new_amount) { 15 }

        it { is_expected.to be_empty }
      end

      context 'when the new transaction date is prior to the reconciliation' do
        let(:old_transaction_date) { 1.day.ago }
        let(:new_transaction_date) { 3.days.ago }

        it { is_expected.to be_present }
      end

      context 'when the new transaction date is after the reconciliation but the old date is prior' do
        let(:old_transaction_date) { 3.days.ago }
        let(:new_transaction_date) { 1.day.ago }

        it { is_expected.to be_present }
      end

      context 'when both old and new transaction dates are after the reconciliation' do
        let(:old_transaction_date) { 1.day.ago }
        let(:new_transaction_date) { 1.day.from_now }
        let(:new_amount) { 15 }

        it { is_expected.to be_empty }
      end
    end

    context 'when trying to delete a transaction' do
      subject(:errors) do
        transaction.destroy
        transaction.errors[:base]
      end

      let(:transaction) do
        create(:transaction, :skip_validations, profile:, transaction_date:)
      end

      context 'when the transaction date is after the reconciliation' do
        let(:transaction_date) { 1.day.ago }

        it { is_expected.to be_empty }
      end

      context 'when the transaction date is prior to the reconciliation' do
        let(:transaction_date) { 4.days.ago }

        it { is_expected.to be_present }
      end
    end
  end

  describe 'validate_category_is_enabled' do
    subject(:errors) do
      transaction.valid?
      transaction.errors[:category_id]
    end

    context 'when creating a transaction' do
      let(:transaction) { build(:transaction, profile:, category:) }

      context 'when the category is nil' do
        let(:category) { nil }

        it { is_expected.to be_empty }
      end

      context 'when the category is enabled' do
        let(:category) { create(:category, :enabled, profile:) }

        it { is_expected.to be_empty }
      end

      context 'when the category is disabled' do
        let(:category) { create(:category, :disabled, profile:) }

        it { is_expected.to eq ['must be enabled'] }
      end
    end

    context 'when updating a transaction where the category is not changed' do
      let(:transaction) { create(:transaction, profile:, category:) }
      let(:category) { create(:category, :enabled, profile:) }

      before { transaction.name = 'Other name' }

      context 'when the category is enabled' do
        it { is_expected.to be_empty }
      end

      context 'when the category is disabled' do
        before do
          allow(Current).to receive(:user).and_return(profile.user)
          category.disable!
        end

        it { is_expected.to be_empty }
      end
    end

    context 'when updating a transaction where the category is changed' do
      let(:transaction) { create(:transaction, profile: profile, category: enabled_category) }
      let(:enabled_category) { create(:category, :enabled, profile:) }
      let(:enabled_category2) { create(:category, :enabled, profile:) }
      let(:disabled_category) { create(:category, :disabled, profile:) }

      before { transaction.category = new_category }

      context 'when the category is nil' do
        let(:new_category) { nil }

        it { is_expected.to be_empty }
      end

      context 'when the category is enabled' do
        let(:new_category) { enabled_category2 }

        it { is_expected.to be_empty }
      end

      context 'when the category is disabled' do
        let(:new_category) { disabled_category }

        it { is_expected.to eq ['must be enabled'] }
      end
    end
  end

  describe 'validate_wallet_is_enabled' do
    subject(:errors) do
      transaction.valid?
      transaction.errors[:wallet_id]
    end

    context 'when creating a transaction' do
      let(:transaction) { build(:transaction, profile:, wallet:) }

      context 'when the wallet is nil' do
        let(:wallet) { nil }

        it { is_expected.to be_empty }
      end

      context 'when the wallet is enabled' do
        let(:wallet) { create(:wallet, :enabled, profile:) }

        it { is_expected.to be_empty }
      end

      context 'when the category is disabled' do
        let(:wallet) { create(:wallet, :disabled, profile:) }

        it { is_expected.to eq ['must be enabled'] }
      end
    end

    context 'when updating a transaction where the wallet is not changed' do
      let(:transaction) { create(:transaction, profile:, wallet:) }
      let(:wallet) { create(:wallet, :enabled, profile:) }

      before { transaction.name = 'Other name' }

      context 'when the wallet is enabled' do
        it { is_expected.to be_empty }
      end

      context 'when the wallet is disabled' do
        before do
          allow(Current).to receive(:user).and_return(profile.user)
          wallet.disable!
        end

        it { is_expected.to be_empty }
      end
    end

    context 'when updating a transaction where the wallet is changed' do
      let(:transaction) { create(:transaction, profile: profile, wallet: enabled_wallet) }
      let(:enabled_wallet) { create(:wallet, :enabled, profile:) }
      let(:enabled_wallet2) { create(:wallet, :enabled, profile:) }
      let(:disabled_wallet) { create(:wallet, :disabled, profile:) }

      before { transaction.wallet = new_wallet }

      context 'when the wallet is nil' do
        let(:new_wallet) { nil }

        it { is_expected.to be_empty }
      end

      context 'when the wallet is enabled' do
        let(:new_wallet) { enabled_wallet2 }

        it { is_expected.to be_empty }
      end

      context 'when the wallet is disabled' do
        let(:new_wallet) { disabled_wallet }

        it { is_expected.to eq ['must be enabled'] }
      end
    end
  end

  describe '#process_amount_type' do
    subject do
      transaction.valid?
      transaction.amount_cents
    end

    let(:transaction) { build(:transaction, amount:) }
    let(:amount) { 9.99 }

    before { transaction.amount_type = amount_type }

    context 'when no amount_type is specified' do
      let(:amount_type) { nil }

      it { is_expected.to eq(999) }
    end

    context 'when amount_type is debit' do
      let(:amount_type) { 'debit' }

      context 'and amount is already negative' do
        let(:amount) { -9.99 }

        it { is_expected.to eq(-999) }
      end

      context 'and amount is positive' do
        let(:amount) { 9.99 }

        it { is_expected.to eq(-999) }
      end
    end

    context 'when amount_type is credit' do
      let(:amount_type) { 'credit' }

      context 'and amount is negative' do
        let(:amount) { -9.99 }

        it { is_expected.to eq(999) }
      end

      context 'and amount is already positive' do
        let(:amount) { 9.99 }

        it { is_expected.to eq(999) }
      end
    end
  end
end
