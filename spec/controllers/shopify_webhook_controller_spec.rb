require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe ShopifyWebhookController do
  describe 'POST order_created' do
    subject { post :order_created, params: { id: 1 } }

    before do
      allow_any_instance_of(described_class).to receive(:verify_webhook).and_return(true)
    end

    context 'order has already been processed before' do
      before do
        OrderEvent.create(shopify_order_id: 1)
      end

      it 'should not create a new OrderEvent' do
        expect { subject }.to change { OrderEvent.count }.by(0)
      end

      it 'should not queue a job' do
        expect { subject }.to change { ProcessOrderEventWorker.jobs.size }.by(0)
      end

      it 'should return 200' do
        subject

        expect(response.status).to eq 200
      end
    end

    context 'order has not been processed before' do
      it 'should create a new OrderEvent if it doesn\'nt already exist' do
        expect { subject }.to change { OrderEvent.count }.by(1)
      end

      it 'should create a new ProcessOrderEventWorker' do
        expect { subject }.to change { ProcessOrderEventWorker.jobs.size }.by(1)
      end

      it 'should return a 200' do
        subject

        expect(response.status).to eq 200
      end
    end


  end
end