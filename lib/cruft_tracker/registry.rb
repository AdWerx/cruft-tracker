# frozen_string_literal: true

# TODO: test me
module CruftTracker
  class Registry
    include Singleton

    attr_accessor :tracked_methods

    def initialize
      @tracked_methods = []
    end

    def <<(tracked_method)
      tracked_methods << tracked_method
    end

    def include?(tracked_method)
      tracked_methods.include?(tracked_method)
    end
  end
end
