require 'rails_helper'

RSpec.describe(CruftTracker) do
  describe '.is_this_method_used?' do
    it 'overrides instance methods on classes that tag methods with is_this_method_used?' do
      expect do
        load './spec/dummy/app/models/class_with_tagged_instance_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      test_class = ClassWithTaggedInstanceMethod.new
      result1 = test_class.some_instance_method
      result2 = test_class.some_instance_method

      expect(result1).to eq('Foobar 1')
      expect(result2).to eq('Foobar 2')
      expect(CruftTracker::Method.count).to eq(1)
      method = CruftTracker::Method.first
      expect(method.owner).to eq('ClassWithTaggedInstanceMethod')
      expect(method.name).to eq('some_instance_method')
      expect(method.method_type).to eq(
        CruftTracker::TrackMethod::INSTANCE_METHOD.to_s
      )
      expect(method.invocations).to eq(2)
      expect(method.deleted_at).to eq(nil)
    end

    it 'overrides class methods on classes that tag methods with is_this_method_used?' do
      expect do
        load './spec/dummy/app/models/class_with_tagged_class_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      result = ClassWithTaggedClassMethod.some_class_method

      expect(result).to eq('Look mom! No hands!')
      expect(CruftTracker::Method.count).to eq(1)
      method = CruftTracker::Method.first
      expect(method.owner).to eq('ClassWithTaggedClassMethod')
      expect(method.name).to eq('some_class_method')
      expect(method.method_type).to eq(
        CruftTracker::TrackMethod::CLASS_METHOD.to_s
      )
      expect(method.invocations).to eq(1)
      expect(method.deleted_at).to eq(nil)
    end

    it 'overrides methods on modules that tag methods with is_this_method_used?' do
      expect do
        load './spec/dummy/app/models/module_with_tagged_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      result = ModuleWithTaggedMethod.some_module_method

      expect(result).to eq('Widdershins')
      expect(CruftTracker::Method.count).to eq(1)
      method = CruftTracker::Method.first
      expect(method.owner).to eq('ModuleWithTaggedMethod')
      expect(method.name).to eq('some_module_method')
      expect(method.method_type).to eq(
        CruftTracker::TrackMethod::CLASS_METHOD.to_s
      )
      expect(method.invocations).to eq(1)
      expect(method.deleted_at).to eq(nil)
    end

    it 'allows the user to disambiguate between class and instance methods with the same name' do
      expect do
        load './spec/dummy/app/models/class_with_class_and_instance_methods_of_the_same_name.rb'
      end.to change { CruftTracker::Method.count }.by(2)

      class_result =
        ClassWithClassAndInstanceMethodsOfTheSameName.some_ambiguous_method_name
      instance_result =
        ClassWithClassAndInstanceMethodsOfTheSameName.new
          .some_ambiguous_method_name

      expect(class_result).to eq(
        'I am the result of a class method invocation!'
      )
      expect(instance_result).to eq(
        'I am the result of an instance method invocation!'
      )
      expect(CruftTracker::Method.count).to eq(2)
      class_method = CruftTracker::Method.first
      expect(class_method.owner).to eq(
        'ClassWithClassAndInstanceMethodsOfTheSameName'
      )
      expect(class_method.name).to eq('some_ambiguous_method_name')
      expect(class_method.method_type).to eq(
        CruftTracker::TrackMethod::CLASS_METHOD.to_s
      )
      expect(class_method.invocations).to eq(1)
      expect(class_method.deleted_at).to eq(nil)
      instance_method = CruftTracker::Method.second
      expect(instance_method.owner).to eq(
        'ClassWithClassAndInstanceMethodsOfTheSameName'
      )
      expect(instance_method.name).to eq('some_ambiguous_method_name')
      expect(instance_method.method_type).to eq(
        CruftTracker::TrackMethod::INSTANCE_METHOD.to_s
      )
      expect(instance_method.invocations).to eq(1)
      expect(instance_method.deleted_at).to eq(nil)
    end

    it 'raises when class and instance methods with the same name are not disambiguated' do
      expect do
        load './spec/dummy/app/models/class_with_class_and_instance_methods_of_the_same_name_that_are_not_disambiguated.rb'
      end.to raise_error(CruftTracker::TrackMethod::AmbiguousMethodType)
    end

    it 'raises when trying to track a method that does not exist' do
      expect do
        load './spec/dummy/app/models/class_tracking_method_that_does_not_exist.rb'
      end.to raise_error(CruftTracker::TrackMethod::NoSuchMethod)
    end

    it 'records distinct stack traces for method invocations' do
      expect do
        load './spec/dummy/app/models/class_with_multiple_backtraces_to_the_same_tracked_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      test_class = ClassWithMultipleBacktracesToTheSameTrackedMethod.new
      test_class.kick_off_the_thing_to_do_twice
      test_class.kick_off_the_thing_to_do

      expect(CruftTracker::Backtrace.count).to eq(2)
      backtrace1 = CruftTracker::Backtrace.first
      method_stack1 = backtrace1.trace.take(5).map { |frame| frame['label'] }
      expect(method_stack1).to eq(
        [
          'do_the_thing',
          'kick_off_the_thing_to_do',
          'block in kick_off_the_thing_to_do_twice',
          'times',
          'kick_off_the_thing_to_do_twice'
        ]
      )
      expect(backtrace1.occurrences).to eq(2)
      backtrace2 = CruftTracker::Backtrace.second
      method_stack2 = backtrace2.trace.take(2).map { |frame| frame['label'] }
      expect(method_stack2).to eq(%w[do_the_thing kick_off_the_thing_to_do])
      expect(backtrace2.occurrences).to eq(1)
    end

    it 'tracks private instance methods' do
      fail
    end

    it 'tracks protected instance methods' do
      fail
    end

    it 'tracks private instance methods' do
      fail
    end

    it 'tracks private class methods' do
      # As in via the eigenclass
      fail
    end
  end
end
