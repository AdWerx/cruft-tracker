# frozen_string_literal: true

module ModuleThatIsTrackingAllMethods
  def self.some_module_method
    'Widdershins'
  end

  def self.be_sneaky
    "you can't see me"
  end

  private_class_method :be_sneaky

  class << self
    private

    def super_private_method
      'kapow'
    end
  end

  def self.do_something_super_privately
    super_private_method
  end
end
