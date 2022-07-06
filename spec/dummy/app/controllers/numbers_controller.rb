# frozen_string_literal: true

class NumbersController < ApplicationController
  NUMBERS = 50.times.map { (SecureRandom.random_number * 1000).round }.freeze

  def index
    @numbers = NUMBERS
  end

  def present
    @number = NUMBERS[params[:id].to_i]

    render 'show'
  end
end
