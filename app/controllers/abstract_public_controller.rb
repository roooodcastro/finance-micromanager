# frozen_string_literal: true

class AbstractPublicController < ApplicationController
  before_action :redirect_to_login

  private

  def redirect_to_login
    return if current_user

    redirect_to login_path
  end
end
