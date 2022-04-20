require 'rails_helper'

RSpec.describe(CruftTracker) do
  describe '.is_this_method_used?' do
    it 'creates method records before methods are invoked' do
      expect do
        load './spec/dummy/app/models/class_with_tagged_instance_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      method = CruftTracker::Method.first
      expect(method.owner).to eq('ClassWithTaggedInstanceMethod')
      expect(method.name).to eq('some_instance_method')
      expect(method.method_type).to eq(
        CruftTracker::TrackMethod::INSTANCE_METHOD.to_s
      )
      expect(method.invocations).to eq(0)
      expect(method.deleted_at).to eq(nil)
    end

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
      method = CruftTracker::Method.first
      backtrace1 = method.backtraces.first
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
      backtrace2 = method.backtraces.second
      method_stack2 = backtrace2.trace.take(2).map { |frame| frame['label'] }
      expect(method_stack2).to eq(%w[do_the_thing kick_off_the_thing_to_do])
      expect(backtrace2.occurrences).to eq(1)
    end

    it 'tracks private instance methods' do
      expect do
        load './spec/dummy/app/models/class_with_private_instance_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      ClassWithPrivateInstanceMethod.new.do_something

      method = CruftTracker::Method.first
      expect(method.owner).to eq(ClassWithPrivateInstanceMethod.name)
      expect(method.name).to eq('some_private_method')
      expect(method.invocations).to eq(1)
    end

    it 'tracks protected instance methods' do
      expect do
        load './spec/dummy/app/models/class_with_protected_instance_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      ClassWithProtectedInstanceMethod.new.do_something

      method = CruftTracker::Method.first
      expect(method.owner).to eq(ClassWithProtectedInstanceMethod.name)
      expect(method.name).to eq('some_protected_method')
      expect(method.invocations).to eq(1)
    end

    it 'tracks private eigenclass methods' do
      expect do
        load './spec/dummy/app/models/class_with_private_eigenclass_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      ClassWithPrivateEigenclassMethod.do_it

      method = CruftTracker::Method.first
      expect(method.owner).to eq(ClassWithPrivateEigenclassMethod.name)
      expect(method.name).to eq('super_private_class_method')
      expect(method.method_type).to eq(
        CruftTracker::TrackMethod::CLASS_METHOD.to_s
      )
      expect(method.invocations).to eq(1)
    end

    it 'tracks private class methods' do
      expect do
        load './spec/dummy/app/models/class_with_private_class_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      ClassWithPrivateClassMethod.do_the_sneaky_thing

      method = CruftTracker::Method.first
      expect(method.owner).to eq(ClassWithPrivateClassMethod.name)
      expect(method.name).to eq('be_sneaky')
      expect(method.method_type).to eq(
        CruftTracker::TrackMethod::CLASS_METHOD.to_s
      )
      expect(method.invocations).to eq(1)
    end

    it 'does not create multiple of the same cruft record in a race condition' do
      starting_pistol_has_been_fired = false

      threads =
        10.times.map do
          Thread.new do
            true while !starting_pistol_has_been_fired
            Class.new do
              def self.name
                'SomeClassName'
              end

              def foo; end
              CruftTracker.is_this_method_used? self, :foo
            end
          end
        end
      starting_pistol_has_been_fired = true
      threads.each(&:join)

      methods =
        CruftTracker::Method.where(
          owner: 'SomeClassName',
          name: 'foo',
          method_type: CruftTracker::TrackMethod::INSTANCE_METHOD
        )
      expect(methods.count).to eq(1)
    end

    it 'does not create multiple of the same stack record in a race condition' do
      starting_pistol_has_been_fired = false
      load './spec/dummy/app/models/class_with_tagged_instance_method.rb'

      threads =
        10.times.map do
          Thread.new do
            true while !starting_pistol_has_been_fired
            ClassWithTaggedInstanceMethod.new.some_instance_method
          end
        end
      starting_pistol_has_been_fired = true
      threads.each(&:join)

      expect(CruftTracker::Backtrace.count).to eq(1)

      # I'm not asserting the exact number of occurrences because we still have a race condition
      # related to having loaded multiple instances of PotentialCruftStack in memory and I don't want
      # to have to jump through a zillion hoops to have exactly correct counts. It's not worth the
      # effort and the impact is low. We could conceivably lose a few occurrence increments, but who
      # cares?
      expect(CruftTracker::Backtrace.first.occurrences).to be > 1
    end

    it 'tracks the method itself, not overrides or super methods' do
      expect do
        load './spec/dummy/app/models/class_with_untracked_method.rb'
        load './spec/dummy/app/models/subclass_with_tracked_method.rb'
        load './spec/dummy/app/models/sub_subclass_with_untracked_method.rb'
        load './spec/dummy/app/models/sub_subclass_with_untracked_method_that_calls_tracked_super_method.rb'
      end.to change { CruftTracker::Method.count }.by(1)

      method = CruftTracker::Method.first

      ClassWithUntrackedMethod.new.hello
      expect(CruftTracker::Method.count).to eq(1)
      expect(method.reload.invocations).to eq(0)

      SubclassWithTrackedMethod.new('Zed').hello
      expect(CruftTracker::Method.count).to eq(1)
      expect(method.reload.invocations).to eq(1)

      SubSubclassWithUntrackedMethod.new('matilda').hello
      expect(CruftTracker::Method.count).to eq(1)
      expect(method.reload.invocations).to eq(1)

      SubSubclassWithUntrackedMethodThatCallsTrackedSuperMethod.new('Clair')
        .hello
      expect(CruftTracker::Method.count).to eq(1)
      expect(method.reload.invocations).to eq(2)
    end

    context 'when the cruft_tracker_methods table does not exist' do
      after do
        ActiveRecord::Base.connection.execute(
          'RENAME TABLE tmp_cruft_tracker_methods TO cruft_tracker_methods'
        )
      end

      it 'prints a warning message' do
        ActiveRecord::Base.connection.execute(
          'RENAME TABLE cruft_tracker_methods TO tmp_cruft_tracker_methods'
        )

        # Note using Zeitwerk with `load` as I am causes the class to be loaded twice. That's no big
        # deal, really. But that's why I'm asserting that we receive warn at least once.
        expect(Rails.logger).to receive(:warn)
          .with(
            'CruftTracker was unable to record a method. Does the cruft_tracker_methods table exist? Have migrations been run?'
          )
          .at_least(:once)

        load './spec/dummy/app/models/class_with_tagged_instance_method.rb'
      end
    end

    context 'with a comment' do
      context 'when the comment is text' do
        it 'writes text' do
          load './spec/dummy/app/models/class_with_textual_comment.rb'

          method = CruftTracker::Method.first

          expect(method.comment).to eq('Tracking is fun!')
        end
      end

      context 'when the comment is serializable to json' do
        it 'writes json' do
          load './spec/dummy/app/models/class_with_hash_comment.rb'

          method = CruftTracker::Method.first

          expect(method.comment).to eq('foo' => true, 'bar' => [1, 'two'])
        end
      end

      context 'when a comment is changed or provided after the initial cruft_tracker_methods record is created' do
        it 'updates the comment' do
          method =
            CruftTracker::Method.create(
              owner: 'ClassWithTextualComment',
              name: 'some_method',
              method_type: CruftTracker::TrackMethod::INSTANCE_METHOD,
              comment: 'Some old comment'
            )

          load './spec/dummy/app/models/class_with_textual_comment.rb'

          expect(method.reload.comment).to eq('Tracking is fun!')
        end
      end
    end

    context 'when track_arguments is not provided' do
      it 'does not track arguments' do
        expect do
          load './spec/dummy/app/models/class_with_method_that_accepts_untracked_arguments.rb'
        end.to change { CruftTracker::Method.count }.by(1)

        ClassWithMethodThatAcceptsUntrackedArguments.new.describe_thing(
          'red',
          123
        )

        method = CruftTracker::Method.first

        expect(method.invocations).to eq(1)
        expect(method.arguments.length).to eq(0)
      end
    end

    context 'when track_arguments is a lambda' do
      it 'tracks distinct transformed arguments provided to the method' do
        load './spec/dummy/app/models/class_with_method_that_accepts_tracked_arguments.rb'

        example = ClassWithMethodThatAcceptsTrackedArguments.new
        example.do_something(
          1,
          'blargh',
          true,
          [2, 'baz', false],
          [{ a: 1, b: 'bar' }, { a: 2, b: 'foo' }],
          x: 213,
          z: 'whatever',
          y: true
        )
        example.do_something(
          2,
          'kapow!',
          true,
          [2, 'baz', false],
          [{ a: 1, b: 'bar' }, { a: 2, b: 'foo' }],
          x: 213,
          z: 'whatever',
          y: true
        )
        example.do_something(
          2,
          'zappo?',
          true,
          [2, 'baz', false],
          [{ a: 1, b: 'bar' }, { a: 2, b: 'foo' }],
          x: 213,
          z: 'whatever',
          y: true
        )

        expect(CruftTracker::Method.count).to eq(1)
        method = CruftTracker::Method.first
        expect(method.arguments.count).to eq(1)
        arguments1 = method.arguments.first
        expect(arguments1.arguments).to eq(%w[x y z])
      end

      it 'does not create multiple of the same arguments record in a race condition' do
        load './spec/dummy/app/models/class_with_method_that_accepts_tracked_arguments.rb'
        starting_pistol_has_been_fired = false

        threads =
          10.times.map do
            Thread.new do
              true while !starting_pistol_has_been_fired
              ClassWithMethodThatAcceptsTrackedArguments.new.do_something(
                1,
                'blargh',
                true,
                [2, 'baz', false],
                [{ a: 1, b: 'bar' }, { a: 2, b: 'foo' }],
                x: 213,
                z: 'whatever',
                y: true
              )
            end
          end
        starting_pistol_has_been_fired = true
        threads.each(&:join)

        expect(CruftTracker::Argument.count).to eq(1)

        # I'm not asserting the exact number of occurrences because we still have a race condition
        # related to having loaded multiple instances of PotentialCruftStack in memory and I don't want
        # to have to jump through a zillion hoops to have exactly correct counts. It's not worth the
        # effort and the impact is low. We could conceivably lose a few occurrence increments, but who
        # cares?
        expect(CruftTracker::Argument.first.occurrences).to be > 1
      end

      context 'when a deleted method record exists for a tracked method' do
        it 'undeletes the record when the class is loaded' do
          method =
            CruftTracker::Method.create(
              owner: 'ClassWithTaggedInstanceMethod',
              name: 'some_instance_method',
              method_type: 'instance_method',
              deleted_at: 1.day.ago
            )

          load './spec/dummy/app/models/class_with_tagged_instance_method.rb'

          expect(method.reload.deleted_at).to be_nil
        end
      end
    end
  end

  describe '#are_any_of_these_methods_used?' do
    it 'tracks all class and instance methods belonging directly to a class' do
      load './spec/dummy/app/models/class_that_is_tracking_all_methods.rb'

      ClassThatIsTrackingAllMethods.do_the_sneaky_thing
      ClassThatIsTrackingAllMethods.do_it
      instance = ClassThatIsTrackingAllMethods.new
      instance.some_method
      instance.some_other_method_name
      instance.kick_off_the_thing_to_do_twice
      instance.do_something
      instance.some_attr = 'Jane'
      instance.hello

      constructor_record = CruftTracker::Method.find_by(name: 'initialize')
      expect(constructor_record.invocations).to eq(1)
      ambiguous_methods =
        CruftTracker::Method.where(name: 'some_ambiguous_method_name')
      expect(ambiguous_methods.size).to eq(2)
      expect(
        CruftTracker::Method.find_by(name: 'do_the_sneaky_thing').invocations
      ).to eq(1)
      expect(CruftTracker::Method.find_by(name: 'be_sneaky').invocations).to eq(
        1
      )
      expect(CruftTracker::Method.find_by(name: 'do_it').invocations).to eq(1)
      expect(
        CruftTracker::Method.find_by(name: 'super_private_class_method')
          .invocations
      ).to eq(1)
      expect(
        CruftTracker::Method.find_by(name: 'some_method').invocations
      ).to eq(1)
      expect(
        CruftTracker::Method.find_by(name: 'some_other_method_name').invocations
      ).to eq(1)
      expect(
        CruftTracker::Method.find_by(name: 'describe_thing').invocations
      ).to eq(0)
      expect(
        CruftTracker::Method.find_by(name: 'kick_off_the_thing_to_do_twice')
          .invocations
      ).to eq(1)
      expect(
        CruftTracker::Method.find_by(name: 'kick_off_the_thing_to_do')
          .invocations
      ).to eq(2)
      expect(
        CruftTracker::Method.find_by(name: 'do_the_thing').invocations
      ).to eq(2)
      expect(
        CruftTracker::Method.find_by(name: 'do_the_thing').invocations
      ).to eq(2)
      expect(
        CruftTracker::Method.find_by(name: 'do_something').invocations
      ).to eq(1)
      expect(
        CruftTracker::Method.find_by(name: 'some_protected_method').invocations
      ).to eq(1)
      expect(CruftTracker::Method.find_by(name: 'hello').invocations).to eq(1)
      expect(
        CruftTracker::Method.find_by(name: 'some_attr=').invocations
      ).to eq(1)
      expect(CruftTracker::Method.find_by(name: 'some_attr').invocations).to eq(
        1
      )
      expect(
        CruftTracker::Method.find_by(name: 'another_untracked_method')
      ).to be_nil
    end

    it 'tracks invocations of all methods on a module' do
      fail
    end
  end
end
