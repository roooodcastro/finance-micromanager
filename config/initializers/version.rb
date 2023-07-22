# frozen_string_literal: true

class Version
  def self.version
    @version ||= File.read('VERSION').strip
  end

  def self.deploy_timestamp
    @deploy_timestamp ||= begin
      File.read('DEPLOY_TIMESTAMP').strip
    rescue Errno::ENOENT
      nil
    end
  end
end
