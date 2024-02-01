# frozen_string_literal: true

module DataGenerator
  class Transactions
    attr_reader :profile, :start_date, :end_date, :transactions_per_day

    INCOME_CATEGORY_NAME = 'Income'

    def initialize(profile_id, start_date, end_date, transactions_per_day = 5)
      @profile              = Profile.find(profile_id)
      @start_date           = start_date.to_date
      @end_date             = end_date.to_date
      @transactions_per_day = transactions_per_day
      @transactions_created = 0
    end

    def generate!
      generate_incomes!
      generate_spends!
    end

    private

    def number_of_days
      end_date - start_date
    end

    def number_of_transactions_to_create
      @number_of_transactions_to_create ||= begin
        random_margin = 1 + (Random.rand(-10..10) * 0.01)
        number_of_days * transactions_per_day * random_margin
      end
    end

    def transaction!(name, amount, category, wallet)
      transaction_date = Random.rand(start_date..end_date)
      created_by       = profile.user
      updated_by       = profile.user

      profile.transactions.create!(name:, transaction_date:, amount:, category:, wallet:, created_by:, updated_by:)
      @transactions_created += 1
    end

    def generate_incomes!
      main_income!
      main_income!
      number_of_secondary_incomes = (number_of_transactions_to_create * 0.05).to_i
      number_of_secondary_incomes.times { secondary_income! }
    end

    def generate_spends!
      num_transactions = number_of_transactions_to_create - @transactions_created
      num_transactions.to_i.times { spend! }
    end

    def main_income!
      name   = %w[Salary Payslip].sample
      amount = 2500 * Random.rand(0.8..2)
      wallet = wallets.sample

      transaction!(name, amount.round(2), income_category, wallet)
    end

    def secondary_income!
      name   = Faker::Hobby.activity
      amount = 5 * Random.rand(0.2..5)
      wallet = wallets.sample

      transaction!(name, amount.round(2), income_category, wallet)
    end

    def spend!
      name     = [Faker::Hobby.activity, Faker::Commerce.vendor,
                  Faker::Restaurant.name, Faker::Construction.subcontract_category].sample
      amount   = Random.rand(1.0..100.0)
      category = categories.sample
      wallet   = wallets.sample

      transaction!(name, amount.round(2) * -1, category, wallet)
    end

    def income_category
      @income_category ||= profile.categories.find_by(name: INCOME_CATEGORY_NAME) || profile.categories.first
    end

    def wallets
      @wallets ||= profile.wallets.to_a
    end

    def categories
      @categories ||= profile.categories.to_a - [income_category]
    end
  end
end
