# -*- encoding : utf-8 -*-
require 'spec_helper'

describe AlaveteliPro::ToDoList::ExpiringEmbargo do
  include Rails.application.routes.url_helpers

  let(:embargo){ FactoryGirl.create(:expiring_embargo) }

  before do
    @expiring_embargo = described_class.new(embargo.user)
  end

  describe '#description' do

    it 'gives a description for one expiring embargo' do
       expect(@expiring_embargo.description).to eq "1 request will be made public this week."
    end

    it 'gives a description for multiple expiring embargoes' do
      FactoryGirl.create(:expiring_embargo, :user => embargo.user)
      expect(@expiring_embargo.description).to eq "2 requests will be made public this week."
    end

  end

  describe '#items' do

    it 'returns the expiring embargoes' do
      expect(@expiring_embargo.items).to eq [embargo]
    end

  end

  describe '#url' do

    context 'when there is one item' do

      it 'returns a link to the embargoed request' do
        expect(@expiring_embargo.url).to eq show_request_path(embargo.info_request.url_title)
      end

    end

    context 'when there is more than one item' do

      it 'returns a link to the info request list with a "embargoed" filter' do
        FactoryGirl.create(:expiring_embargo, :user => embargo.user)
        expect(@expiring_embargo.url)
          .to eq alaveteli_pro_info_requests_path('alaveteli_pro_request_filter[filter]' =>
                                                    'embargoes_expiring')
      end

    end

  end

  describe '#call_to_action' do

    context 'when there is one item' do

      it 'returns an appropriate text' do
        expect(@expiring_embargo.call_to_action).to eq 'Publish this request or keep it private for longer.'
      end

    end

    context 'when there is more than one item' do

      it 'returns an appropriate text' do
        FactoryGirl.create(:expiring_embargo, :user => embargo.user)
        expect(@expiring_embargo.call_to_action).to eq 'Publish these requests or keep them private for longer.'
      end

    end

  end

end
