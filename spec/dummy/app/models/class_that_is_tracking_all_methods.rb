# frozen_string_literal: true

class ClassThatIsTrackingAllMethods < ClassWithUntrackedMethod
  attr_accessor :some_attr

  def initialize
    @some_attr = 'Bob'
  end

  def self.some_ambiguous_method_name
    'I am the result of a class method invocation!'
  end

  def self.do_the_sneaky_thing
    be_sneaky
  end

  def self.be_sneaky
    "you can't see me"
  end

  private_class_method :be_sneaky

  class << self
    private

    def super_private_class_method
      'kapow'
    end
  end

  def self.do_it
    self.super_private_class_method
  end

  def some_ambiguous_method_name
    'I am the result of an instance method invocation!'
  end

  def some_method
    'Woot'
  end

  alias_method :some_other_method_name, :some_method

  def describe_thing(color, weight)
    "The thing is #{color} and weighs #{weight} firkins."
  end

  def kick_off_the_thing_to_do_twice
    2.times { kick_off_the_thing_to_do }
  end

  def kick_off_the_thing_to_do
    do_the_thing
  end

  def do_something
    some_protected_method
  end

  def hello
    "Hi, #{some_attr}"
  end

  protected

  def some_protected_method
    'I am safely protected'
  end

  private

  def do_the_thing
    'I am tracked'
  end

  CruftTracker.are_any_of_these_methods_being_used? self
end
