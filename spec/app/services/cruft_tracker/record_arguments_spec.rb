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
  end
end
