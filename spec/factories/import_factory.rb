# frozen_string_literal: true

FactoryBot.define do
  factory :import do
    source_file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/n26.csv'), 'text/csv') }
    source { 'ptsb' }

    profile
    wallet

    trait :ptsb do
      source { 'ptsb' }
    end

    trait :n26 do
      source { 'n26' }
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
