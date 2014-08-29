require 'spec_helper'

describe Market do

  it "should raise argument error on invalid market id" do
    expect { Market.new(id: 'dogechf') }.to raise_error(ArgumentError)
    expect { Market.new(id: 'dogchf') }.not_to raise_error
  end

  context 'visible market' do
    # it { expect(Market.orig_all.count).to eq(2) }
    it { expect(Market.all.count).to eq(1) }
  end

  context 'market attributes' do
    subject { Market.find('btccny') }

    its(:id)          { should == 'btccny' }
    its(:name)        { should == 'BTC/CNY' }
    its(:target_unit) { should == 'btc' }
    its(:price_unit)  { should == 'cny' }
    its(:visible)     { should be_true }
  end

  context 'enumerize' do
    subject { Market.enumerize }

    it { should be_has_key :btccny }
    it { should be_has_key :ptsbtc }
  end

end
