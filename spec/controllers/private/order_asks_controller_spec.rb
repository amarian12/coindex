require 'spec_helper'

describe Private::OrderAsksController do

  let(:member) do
    create(:member).tap {|m|
      m.get_account('btc').update_attributes(balance: '20')
    }
  end

  let(:market) { Market.find('ltcbtc') }
  let(:params) do
    { market_id: market.id,
      market:    market.id,
      ask:       market.base_unit,
      bid:       market.quote_unit,
      order_ask: { ord_type: 'limit', origin_volume: '12.13', price: '2014.47' }
    }
  end

  context 'POST :create' do
    it "should create a sell order" do
      expect {
        post :create, params, {member_id: member.id}
        response.should be_success
        response.body.should == '{"result":true,"message":"Order submitted successfully"}'
      }.to change(OrderAsk, :count).by(1)
    end

    it "should set order source to Web" do
      post :create, params, {member_id: member.id}
      assigns(:order).source.should == 'Web'
    end
  end

end
