require 'rails_helper'

RSpec.describe CruftTracker::LogSuppressor do
  it 'sets log level back to original log level' do
    original_log_level = ActiveRecord::Base.logger.level

    expect do
      CruftTracker::LogSuppressor.suppress_logging { raise 'error' }
    end.to raise_error('error')
    expect(ActiveRecord::Base.logger.level).to eq(original_log_level)
  end
end
