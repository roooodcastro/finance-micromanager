# frozen_string_literal: true

class ServiceWorkerController < ApplicationController
  protect_from_forgery except: :service_worker

  skip_before_action :set_current_attributes

  def service_worker; end

  def manifest; end
end
