require 'rails_helper'

describe ProcessOrderCancellationWorker do
  describe 'perform' do
    subject { described_class.new.perform(order_event.id) }

    let(:order_event) { OrderEvent.create(shopify_order_id: 1) }

    let(:hash) {
      {
          envelope: {
              body: {
                  cancelorder_response: {
                      ret: 0
                  }
              }
          }
      }
    }

    before do
      allow(Logon).to receive(:cancel_order).and_return(OpenStruct.new(hash: hash))
    end

    it 'should set the order event to cancelled' do
      subject

      expect(order_event.reload.cancelled).to eq true
    end
  end
end