require 'rails_helper'
require 'support/auth_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

include AuthHelper

describe LogonCallbacksController do
  describe '#update_variant_quantity' do
    subject do
      post :update_variant_quantity, params: params

      response
    end

    before do
      Sidekiq::Worker.clear_all
    end

    let(:variant) { Variant.create(logon_style: 'style', logon_col: 'col', logon_dm: 'dm', logon_size: 'size', )}
    let(:params) { { style: variant.logon_style, col: variant.logon_col, dm: variant.logon_dm, size: variant.logon_size } }

    context 'with incorrect credentials' do
      before do
        http_login(user: 'nope', pw: 'incorrect')
      end

      it { expect(subject.status).to eq 401 }
      it { expect { subject }.to change { UpdateVariantQuantityWorker.jobs.size }.by(0) }
    end

    context 'with correct credentials' do
      before do
        http_login
      end

      context 'when we can\'t find the variant in question' do
        let(:params) { { style: 'nope', col: 'nope', dm: 'nope', size: 'nope' } }

        it { expect(subject.status).to eq 404 }
        it { expect { subject }.to change { UpdateVariantQuantityWorker.jobs.size }.by(0) }

        it 'should return the error details in JSON' do
          subject

          body = JSON.parse(response.body)

          expect(body['error']['code']).to eq 'variant_not_found'
          expect(body['error']['message']).not_to be_empty
        end
      end

      context 'when we can find the variant in question' do
        it { expect(subject.status).to eq 200 }
        it { expect { subject }.to change { UpdateVariantQuantityWorker.jobs.size }.by(1) }
      end
    end
  end
end