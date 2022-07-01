require 'rails_helper'

RSpec.describe(CruftTracker::RecordViewRender) do
  describe '#run!' do
    context 'when the controller, endpoint, route, and render stack have not been seen together before' do
      it 'records a new metadata record' do
        fail
      end
    end

    context 'when the controller, endpoint, route, and render stack have been seen together before' do
      it 'increments the number of occurrences' do
        fail
      end
    end
  end
end
