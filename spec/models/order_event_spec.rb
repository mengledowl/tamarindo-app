require 'rails_helper'

describe OrderEvent do
  subject { OrderEvent.new }

  it 'should default cancelled to false' do
    expect(subject.cancelled).to eq false
  end
end