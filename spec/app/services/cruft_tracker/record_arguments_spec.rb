require 'rails_helper'

RSpec.describe(CruftTracker::RecordArguments) do
  describe '#run!' do
    it 'records new occurrences of arguments for a method' do
      method_record =
        CruftTracker::Method.create(
          owner: 'SomeImaginaryClass',
          name: 'some_method_that_accepts_arguments',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )

      arguments_record =
        CruftTracker::RecordArguments.run!(
          method: method_record,
          arguments: ['hi', { a: 123, b: 'def' }],
          transformer: ->(args) { [args.length, args.second.keys] }
        )

      expect(arguments_record.occurrences).to eq(1)
      expect(arguments_record.arguments).to eq([2, %w[a b]])
    end

    it 'increments occurrences of already-seen arguments for a method' do
      method_record =
        CruftTracker::Method.create(
          owner: 'SomeImaginaryClass',
          name: 'some_method_that_accepts_arguments',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )
      existing_arguments_record =
        CruftTracker::Argument.create(
          method: method_record,
          arguments_hash: 'de876de6c63fcf5703bc82eeddc6810c',
          arguments: [2, %w[a b]],
          occurrences: 123
        )

      CruftTracker::RecordArguments.run!(
        method: method_record,
        arguments: ['hi', { a: 123, b: 'def' }],
        transformer: ->(args) { [args.length, args.second.keys] }
      )

      expect(existing_arguments_record.reload.occurrences).to eq(124)
    end

    it 'does not create more records than permitted by configuration' do
      method_record1 =
        CruftTracker::Method.create(
          owner: 'SomeImaginaryClass',
          name: 'some_method_that_accepts_arguments',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )
      method_record2 =
        CruftTracker::Method.create(
          owner: 'OtherImaginaryClass',
          name: 'other_method_that_accepts_arguments',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )
      allow(CruftTracker::Config.instance).to receive(:max_argument_variations_per_tracked_method).and_return(2)

      4.times.each_with_index do|i|
        CruftTracker::RecordArguments.run!(
          method: method_record1,
          arguments: [{ index: i }],
          transformer: ->(args) { args }
        )
      end
      CruftTracker::RecordArguments.run!(
        method: method_record2,
        arguments: [true, false],
        transformer: ->(args) { args }
      )

      expect(CruftTracker::Argument.where(method: method_record1).count).to eq(2)
      expect(CruftTracker::Argument.where(method: method_record2).count).to eq(1)
    end
  end
end
