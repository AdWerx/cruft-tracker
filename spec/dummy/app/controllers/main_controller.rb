# frozen_string_literal: true

class MainController < ApplicationController
  helper_method :uuid

  def show
    @name = "Zamboni Overdrive"
  end

  private

  def uuid
    SecureRandom.uuid
  end
end
