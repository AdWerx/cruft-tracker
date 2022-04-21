# frozen_string_literal: true

module CruftTracker
  class Registry
    include Singleton

    attr_accessor :tracked_methods

    def self.<<(tracked_method)
      instance.tracked_methods << tracked_method
    end

    def self.include?(tracked_method)
      instance.tracked_methods.include?(tracked_method)
    end

    def self.reset
      instance.tracked_methods = []
    end

    def initialize
      @tracked_methods = []
    end
  end
end
