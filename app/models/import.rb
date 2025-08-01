# frozen_string_literal: true

class Import < ApplicationRecord
  MAX_UPLOAD_FILE_SIZE = 10.megabytes

  has_one_attached :source_file, dependent: :destroy

  belongs_to :profile
  belongs_to :wallet

  has_many :transactions, dependent: :restrict_with_exception
  has_many :import_transactions, class_name: 'TransactionImports::ImportTransaction',
                                 dependent:  :restrict_with_exception

  enum :source, { ptsb: 'ptsb', n26: 'n26', revolut: 'revolut', sheets: 'sheets' }
  enum :status, { in_progress: 'in_progress', finished: 'finished', cancelled: 'cancelled' }, default: 'in_progress'

  validates :source, presence: true, unless: :cancelled?
  validates :source_file,
            attached:     true,
            content_type: %w[text/csv application/vnd.ms-excel application/pdf],
            size:         { less_than: MAX_UPLOAD_FILE_SIZE }

  def as_json
    super.merge(wallet: wallet.as_json, file_name: source_file.blob&.filename.to_s)
  end

  def cancelled!(error_message = nil)
    update(status: :cancelled)
    errors.add(:base, error_message) if error_message
    true
  end

  def minimum_transaction_date
    # rubocop:disable Style/SafeNavigation
    @minimum_transaction_date ||= profile.latest_reconciliation ? profile.latest_reconciliation.date + 1.day : nil
    # rubocop:enable Style/SafeNavigation
  end
end
