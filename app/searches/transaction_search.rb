# frozen_string_literal: true

class TransactionSearch
  attr_reader :relation, :query_params

  def initialize(relation, query_params)
    @relation     = relation
    @query_params = default_search_params.merge(query_params)
  end

  def search
    search_exclude_debits
    search_exclude_credits
    search_days_to_show
    search_start_date
    search_end_date
    search_category_ids
    search_wallet_ids

    relation
  end

  def search_date_range_only
    search_start_date
    search_end_date

    relation
  end

  def search_exclude_debits
    return self unless query_params.key?(:exclude_debits)
    return self unless ActiveRecord::Type::Boolean.new.deserialize(query_params[:exclude_debits])

    @relation = relation.exclude_debits
    self
  end

  def search_exclude_credits
    return self unless query_params.key?(:exclude_credits)
    return self unless ActiveRecord::Type::Boolean.new.deserialize(query_params[:exclude_credits])

    @relation = relation.exclude_credits
    self
  end

  def search_days_to_show
    return self if !query_params.key?(:days_to_show) || query_params[:days_to_show].to_i.zero?

    @relation = relation.newer_than(query_params[:days_to_show].to_i.days.ago)
    self
  end

  def search_start_date
    return self unless query_params.key?(:start_date)

    @relation = relation.newer_than(query_params[:start_date])
    self
  end

  def search_end_date
    return self unless query_params.key?(:end_date)

    @relation = relation.older_than(query_params[:end_date])
    self
  end

  def search_category_ids
    return self unless query_params.key?(:category_ids)

    category_ids, subcategory_ids = parse_category_ids
    base_relation                 = relation

    if category_ids.present?
      @relation = relation.where(category_id: category_ids)
      @relation = relation.or(base_relation.where(subcategory_id: subcategory_ids)) if subcategory_ids.present?
    elsif subcategory_ids.present?
      @relation = relation.where(subcategory_id: subcategory_ids)
    end

    self
  end

  def search_wallet_ids
    return self if !query_params.key?(:wallet_ids) || query_params[:wallet_ids].blank?

    wallet_ids                              = query_params[:wallet_ids].split(',')
    unspecified_wallet_id_index             = wallet_ids.index('null')
    wallet_ids[unspecified_wallet_id_index] = nil if unspecified_wallet_id_index

    @relation                               = relation.where(wallet_id: wallet_ids)
    self
  end

  def parse_category_ids
    category_ids_raw = query_params[:category_ids].split(',')
    category_ids     = category_ids_raw.map do |id_raw|
      next if id_raw.include?('|')

      id_raw.split('|')[0]
    end.compact

    subcategory_ids = category_ids_raw.map { |id_raw| id_raw.split('|')[1] }.compact

    [category_ids, subcategory_ids]
  end

  def default_search_params
    { days_to_show: 30 }
  end
end
