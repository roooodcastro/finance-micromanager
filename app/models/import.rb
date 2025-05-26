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
end
