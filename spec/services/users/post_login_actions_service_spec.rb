# frozen_string_literal: true

RSpec.describe Users::PostLoginActionsService, type: :service do
  describe '.call' do
    subject(:call) { described_class.call(user) }

    let(:user) { create(:user) }
    let(:profile1) { create(:profile, user:) }
    let(:profile2) { create(:profile, user:) }

    it 'calls Budgets::CreateBudgetInstancesService for each of the user\'s profiles' do
      allow(Budgets::CreateBudgetInstancesService).to receive(:call_for_profile)
      expect(Budgets::CreateBudgetInstancesService).to receive(:call_for_profile).with(profile1).once
      expect(Budgets::CreateBudgetInstancesService).to receive(:call_for_profile).with(profile2).once

      call
    end
  end
end
