# frozen_string_literal: true

RSpec.describe CacheLatestUpdatedAt do
  let(:concrete_class) { Category }
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:profile) { create(:profile) }
  let(:cache_key) { concrete_class.latest_updated_at_cache_key(profile.id) }

  before do
    allow(Current).to receive(:profile).and_return(profile)
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe 'after_commit' do
    before { Rails.cache.write(cache_key, Time.current) }

    context 'when the record is being created' do
      context 'and the profile matches' do
        subject(:after_commit) { create(:category, profile:) }

        it 'deletes the cache' do
          expect { after_commit }.to change { Rails.cache.read(cache_key) }.to(nil)
        end
      end

      context 'and the profile does not match' do
        subject(:after_commit) { create(:category) }

        it 'does not delete the cache' do
          expect { after_commit }.not_to change { Rails.cache.read(cache_key) }
        end
      end
    end

    context 'when the record is being updated' do
      subject(:after_commit) { category.update(name: 'Another') }

      before do
        category
        Rails.cache.write(cache_key, Time.current)
      end

      context 'and the profile matches' do
        let(:category) { create(:category, profile:) }

        it 'deletes the cache' do
          expect { after_commit }.to change { Rails.cache.read(cache_key) }.to(nil)
        end
      end

      context 'and the profile does not match' do
        let(:category) { create(:category) }

        it 'does not delete the cache' do
          expect { after_commit }.not_to change { Rails.cache.read(cache_key) }
        end
      end
    end

    context 'when the record is being destroyed' do
      subject(:after_commit) { category.destroy }

      before do
        category
        Rails.cache.write(cache_key, Time.current)
      end

      context 'and the profile matches' do
        let(:category) { create(:category, profile:) }

        it 'deletes the cache' do
          expect { after_commit }.to change { Rails.cache.read(cache_key) }.to(nil)
        end
      end

      context 'and the profile does not match' do
        let(:category) { create(:category) }

        it 'does not delete the cache' do
          expect { after_commit }.not_to change { Rails.cache.read(cache_key) }
        end
      end
    end
  end

  describe '#latest_updated_at' do
    subject(:latest_updated_at) { concrete_class.latest_updated_at }

    let(:max_updated_at) { 1.minute.ago.change(usec: 0) }

    context 'when there is no cache' do
      context 'and there are no records in the table' do
        it { is_expected.to be_nil }
      end

      context 'and there are some records for the same profile' do
        before { travel_to(max_updated_at) { create(:category, profile:) } }

        it 'fetches the timestamp from the database' do
          expect(concrete_class).to receive(:where).and_call_original
          expect(latest_updated_at).to eq max_updated_at
        end
      end

      context 'and there are some records for another profile' do
        before { travel_to(max_updated_at) { create(:category) } }

        it 'fetches the timestamp from the database but returns nil' do
          expect(concrete_class).to receive(:where).and_call_original
          expect(latest_updated_at).to be_nil
        end
      end
    end

    context 'when there is a cache already' do
      before { Rails.cache.write(cache_key, max_updated_at) }

      it 'fetches the timestamp from the cache' do
        expect(concrete_class).not_to receive(:where).and_call_original
        expect(latest_updated_at).to eq max_updated_at
      end
    end

    context 'when the class overrides the default logic' do
      let(:concrete_class) { Subcategory }

      before do
        category = create(:category, profile:)
        travel_to(max_updated_at) { create(:subcategory, category:) }
      end

      it 'fetches the timestamp from the database' do
        expect(concrete_class).to receive(:joins).and_call_original
        expect(latest_updated_at).to eq max_updated_at
      end
    end
  end
end
