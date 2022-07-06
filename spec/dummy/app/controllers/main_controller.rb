# frozen_string_literal: true

class MainController < ApplicationController
  helper_method :uuid

  def show
    @name = "Zamboni Overdrive"
    @some_value = ClassWithTextualComment.new.some_method
  end

  private

  def uuid
    SecureRandom.uuid
  end
end
