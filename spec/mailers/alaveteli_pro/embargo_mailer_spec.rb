# -*- encoding : utf-8 -*-
require 'spec_helper'

describe AlaveteliPro::EmbargoMailer do
  let(:pro_user) { FactoryGirl.create(:pro_user) }
  let(:pro_user_2) { FactoryGirl.create(:pro_user) }
  let(:embargo_extension) { FactoryGirl.create(:embargo_extension) }

  let!(:expiring_1) do
    FactoryGirl.create(:embargo_expiring_request, user: pro_user)
  end
  let!(:expiring_2) do
    FactoryGirl.create(:embargo_expiring_request, user: pro_user)
  end
  let!(:expiring_3) do
    FactoryGirl.create(:embargo_expiring_request, user: pro_user_2)
  end
  let!(:embargoed) { FactoryGirl.create(:embargoed_request) }
  let!(:not_embargoed) { FactoryGirl.create(:info_request) }

  describe '.alert_expiring' do
    it 'only sends one email per user' do
      AlaveteliPro::EmbargoMailer.alert_expiring
      mails = ActionMailer::Base.deliveries
      expect(mails.size).to eq 2
      first_mail = mails.detect{ |mail| mail.to == [pro_user.email] }
      second_mail = mails.detect{ |mail| mail.to == [pro_user_2.email] }
      expect(first_mail).not_to be nil
      expect(second_mail).not_to be nil
    end

    it 'only sends an alert about an expiring embargo once' do
      AlaveteliPro::EmbargoMailer.alert_expiring
      expect(ActionMailer::Base.deliveries.size).to eq 2

      ActionMailer::Base.deliveries.clear
      AlaveteliPro::EmbargoMailer.alert_expiring
      expect(ActionMailer::Base.deliveries.size).to eq 0
    end

    it 'sends an alert about an expiring embargo extension' do
      AlaveteliPro::EmbargoMailer.alert_expiring
      expect(ActionMailer::Base.deliveries.size).to eq 2

      ActionMailer::Base.deliveries.clear
      expiring_3.embargo.extend(embargo_extension)
      time_travel_to(AlaveteliPro::Embargo.three_months_from_now - 3.days) do
        AlaveteliPro::EmbargoMailer.alert_expiring
        mails = ActionMailer::Base.deliveries
        expect(mails.detect{ |mail| mail.to == [pro_user_2.email] }).
          not_to be_nil
      end
    end

    it 'creates UserInfoRequestSentAlert records for each expiring request' do
      expect(UserInfoRequestSentAlert.where(
        info_request_id: expiring_1.id,
        user_id: pro_user.id)
      ).not_to exist
      expect(UserInfoRequestSentAlert.where(
        info_request_id: expiring_2.id,
        user_id: pro_user.id)
      ).not_to exist
      expect(UserInfoRequestSentAlert.where(
        info_request_id: expiring_3.id,
        user_id: pro_user_2.id)
      ).not_to exist

      AlaveteliPro::EmbargoMailer.alert_expiring

      expect(UserInfoRequestSentAlert.where(
        info_request_id: expiring_1.id,
        user_id: pro_user.id)
      ).to exist
      expect(UserInfoRequestSentAlert.where(
        info_request_id: expiring_2.id,
        user_id: pro_user.id)
      ).to exist
      expect(UserInfoRequestSentAlert.where(
        info_request_id: expiring_3.id,
        user_id: pro_user_2.id)
      ).to exist
    end
  end

  describe '#expiring_alert' do
    context "when there's just one embargo" do
      before do
        AlaveteliPro::EmbargoMailer.expiring_alert(pro_user, [expiring_1])
        @mail = ActionMailer::Base.deliveries[0]
      end

      it 'sets the subject correctly for a single embargo' do
        expected_subject = '1 request will be made public on Alaveteli this week'
        expect(@mail.subject).to eq expected_subject
      end

      it "prints the message correctly" do
        expected_body = "The following request will be made public on Alaveteli in the " \
                        "next week. If you do not wish this request to go public at that " \
                        "time, please click on the link below to keep it private for longer.\n\n" \
                        "  #{request_url(expiring_1)}\n\n" \
                        "-- the #{AlaveteliConfiguration.site_name} team\n"
        expect(@mail.body).to eq expected_body
      end

      it "sends the email to the user" do
        expect(@mail.to).to eq [pro_user.email]
      end

      it "sends the email from the pro contact address" do
        expect(@mail.from).to eq [AlaveteliConfiguration.pro_contact_email]
      end
    end

    context "when there are multiple embargoes" do
      before do
        AlaveteliPro::EmbargoMailer.expiring_alert(pro_user, [expiring_1, expiring_2])
        @mail = ActionMailer::Base.deliveries[0]
      end

      it 'sets the subject correctly' do
        expected_subject = '2 requests will be made public on Alaveteli this week'
        expect(@mail.subject).to eq expected_subject
      end

      it "prints the message correctly" do
        expected_body = "The following requests will be made public on Alaveteli in the " \
                        "next week. If you do not wish for any of these requests to go " \
                        "public, please click on the links below to extend them.\n\n" \
                        "  #{request_url(expiring_1)}\n" \
                        "  #{request_url(expiring_2)}\n\n" \
                        "-- the #{AlaveteliConfiguration.site_name} team\n"
        expect(@mail.body).to eq expected_body
      end

      it "sends the email to the user" do
        expect(@mail.to).to eq [pro_user.email]
      end

      it "sends the email from the pro contact address" do
        expect(@mail.from).to eq [AlaveteliConfiguration.pro_contact_email]
      end
    end
  end
end
