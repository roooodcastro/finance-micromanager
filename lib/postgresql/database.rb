# frozen_string_literal: true

module Postgresql
  class Database
    def dump(debug: false, include_globals: false)
      globals_file_path = File.join(backup_folder, "#{file_name}_globals.sql")
      db_file_path      = File.join(backup_folder, "#{file_name}_#{database}.sql")

      # Dump users/roles/permissions global to the PostgreSQL instance
      if include_globals
        cmd = "PGPASSWORD='#{password}' pg_dumpall --globals-only -U '#{user}' -h '#{host}' " \
              "-f '#{globals_file_path}' -p '#{port}' && gzip #{globals_file_path}"
        debug ? system(cmd) : system(cmd, err: File::NULL)
      end

      # Dump application database
      cmd = "PGPASSWORD='#{password}' pg_dump -F p -v -O -U '#{user}' -h '#{host}' -d '#{database}' " \
            "-f '#{db_file_path}' -p '#{port}' && gzip #{db_file_path}"
      debug ? system(cmd) : system(cmd, err: File::NULL)

      include_globals ? %W[#{globals_file_path}.gz #{db_file_path}.gz] : [nil, "#{db_file_path}.gz"]
    end

    private

    def db_config
      @db_config ||= ::ActiveRecord::Base.connection_db_config.configuration_hash
    end

    def host
      db_config[:host]
    end

    def port
      db_config[:port]
    end

    def database
      db_config[:database]
    end

    def user
      db_config[:username]
    end

    def password
      db_config[:password]
    end

    def file_name
      @file_name ||= Time.current.strftime('%Y%m%d%H%M%S')
    end

    def backup_folder
      Rails.root.join('tmp/postgresql_backup').tap { |folder| FileUtils.mkdir_p(folder) }
    end
  end
end
