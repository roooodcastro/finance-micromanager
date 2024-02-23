# frozen_string_literal: true

require 'sidekiq-scheduler'
require 'postgresql/database'

module Postgresql
  class BackupDatabaseJob < ApplicationJob
    queue_as :default

    def perform
      database_filename = Postgresql::Database.new.dump(include_globals: false)[1]

      file = File.open(database_filename)
      key  = Pathname.new(database_filename).basename.to_s

      ActiveStorage::Blob.create_and_upload!(key: key, io: file, filename: key)
    rescue StandardError => e
      SystemMailer.database_backup_error(e).deliver_now
    end
  end
end
