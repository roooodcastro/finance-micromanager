# frozen_string_literal: true

RSpec.describe Category do
  describe '#temporary_category_for' do
    subject(:temporary_category_for) { described_class.temporary_category_for(account) }

    let(:account) { create(:account) }

    context 'when a temporary category does not yet exist' do
      it 'creates a new temporary category' do
        expect { temporary_category_for }.to change { described_class.count }.by(1)
      end
    end

    context 'when a temporary category already exists' do
      let!(:temporary_category) { create(:category, account: account, name: 'Temporary', color: '#808080') }

      it { is_expected.to eq(temporary_category) }

      it 'does not create a new temporary category' do
        expect { temporary_category_for }.not_to change { described_class.count }
      end
    end

    context 'when a temporary category already exists but for another account' do
      let(:account2) { create(:account) }

      let!(:temporary_category) { create(:category, account: account2, name: 'Temporary', color: '#808080') }

      it { is_expected.not_to eq(temporary_category) }

      it 'creates a new temporary category' do
        expect { temporary_category_for }.to change { described_class.count }.by(1)
      end
    end
  end
end
