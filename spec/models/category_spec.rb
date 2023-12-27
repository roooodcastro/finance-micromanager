# frozen_string_literal: true

RSpec.describe Category do
  describe '#reconciliation_category_for' do
    subject(:reconciliation_category_for) { described_class.reconciliation_category_for(profile) }

    let(:profile) { create(:profile) }

    context 'when the category does not yet exist' do
      it 'creates a new reconciliation category' do
        expect { reconciliation_category_for }.to change { described_class.count }.by(1)
      end
    end

    context 'when a temporary category already exists' do
      let!(:reconciliation_category) do
        create(:category, profile: profile, name: 'reconciliations.category_name', color: '#808080',
               category_type: :system)
      end

      it 'does not create a new temporary category' do
        expect { reconciliation_category_for }.not_to change { described_class.count }
        expect(reconciliation_category_for).to eq(reconciliation_category)
      end
    end

    context 'when a temporary category already exists but for another profile' do
      let(:profile2) { create(:profile) }

      let!(:reconciliation_category) do
        create(:category, profile: profile2, name: 'reconciliations.category_name', color: '#808080',
               category_type: :system)
      end

      it 'creates a new temporary category' do
        expect { reconciliation_category_for }.to change { described_class.count }.by(1)
        expect(reconciliation_category_for).not_to eq(reconciliation_category)
      end
    end
  end

  describe '#temporary_category_for' do
    subject(:temporary_category_for) { described_class.temporary_category_for(profile) }

    let(:profile) { create(:profile) }

    context 'when a temporary category does not yet exist' do
      it 'creates a new temporary category' do
        expect { temporary_category_for }.to change { described_class.count }.by(1)
      end
    end

    context 'when a temporary category already exists' do
      let!(:temporary_category) do
        create(:category, profile: profile, name: 'Temporary', color: '#808080', category_type: :system)
      end

      it { is_expected.to eq(temporary_category) }

      it 'does not create a new temporary category' do
        expect { temporary_category_for }.not_to change { described_class.count }
      end
    end

    context 'when a temporary category already exists but for another profile' do
      let(:profile2) { create(:profile) }

      let!(:temporary_category) do
        create(:category, profile: profile2, name: 'Temporary', color: '#808080', category_type: :system)
      end

      it { is_expected.not_to eq(temporary_category) }

      it 'creates a new temporary category' do
        expect { temporary_category_for }.to change { described_class.count }.by(1)
      end
    end
  end

  describe '#validate_system_category' do
    subject { category.valid? }

    context 'when creating a system category' do
      let(:category) { build(:category, :system) }

      it { is_expected.to be(true) }
    end

    context 'when updating a system category' do
      let(:category) { create(:category, :system) }

      it 'does not allow changes' do
        expect(category.update(name: 'New Name')).to be_falsey
        expect(category.errors.full_messages[0]).to eq('Cannot edit system categories')
      end
    end
  end
end
