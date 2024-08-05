# frozen_string_literal: true

FactoryBot.define do
  factory :import do
    source_file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/n26.csv'), 'text/csv') }
    source { 'ptsb' }

    profile
    wallet

    trait :ptsb do
      source { 'ptsb' }
      source_file do
        Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/ptsb.xls'),
                                     'application/vnd.ms-excel')
      end
    end

    trait :n26 do
      source { 'n26' }
      source_file do
        Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/n26.csv'), 'text/csv')
      end
    end

    trait :revolut do
      source { 'revolut' }
      source_file do
        Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/revolut.csv'), 'text/csv')
      end
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :finished do
      status { :finished }
    end
  end
end
