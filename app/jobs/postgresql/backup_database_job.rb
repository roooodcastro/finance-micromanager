# frozen_string_literal: true

require 'sidekiq-scheduler'
require 'postgresql/database'

module Postgresql
  class BackupDatabaseJob < ApplicationJob
    queue_as :default

    def perform
      database_filename = Postgresql::Database.new.dump(include_globals: false)[1]
      SystemMailer.database_backup_created(database_filename).deliver_now
    end
  end
end
