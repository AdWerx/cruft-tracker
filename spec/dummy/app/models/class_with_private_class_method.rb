# frozen_string_literal: true

class ClassWithPrivateClassMethod
  def self.do_the_sneaky_thing
    be_sneaky
  end

  def self.be_sneaky
    "you can't see me"
  end

  private_class_method :be_sneaky
end
