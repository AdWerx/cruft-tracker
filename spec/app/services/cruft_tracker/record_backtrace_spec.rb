require 'rails_helper'

RSpec.describe(CruftTracker::RecordBacktrace) do
  describe '#run!' do
    # NOTE: I'm not testing multiple occurrences of the same stack. That's difficult to accomplish
    # in a test and I suspect it's not worth the trouble to figure out how to do it. I hope.
    it 'records backtraces for method invocation' do
      method_record =
        CruftTracker::Method.create(
          owner: 'SomeImaginaryClass',
          name: 'some_method_that_accepts_arguments',
          method_type: CruftTracker::Method::INSTANCE_METHOD
        )

      CruftTracker::RecordBacktrace.run!(method: method_record)

      expect(CruftTracker::Backtrace.count).to eq(1)
      expect(CruftTracker::Backtrace.first.occurrences).to eq(1)
    end

    it 'does not create more records than permitted by configuration' do
      CruftTracker.is_this_method_used?(ClassWithHashComment, :some_method)
      allow(CruftTracker::Config.instance).to receive(:max_backtrace_variations_per_tracked_method).and_return(2)

      ClassWithHashComment.new.some_method
      ClassWithHashComment.new.some_method
      ClassWithHashComment.new.some_method
      ClassWithHashComment.new.some_method

      expect(CruftTracker::Backtrace.count).to eq(2)
    end
  end
end
