# -*- encoding : utf-8 -*-
# == Schema Information
# Schema version: 20170328100359
#
# Table name: info_request_batches
#
#  id               :integer          not null, primary key
#  title            :text             not null
#  user_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  body             :text
#  sent_at          :datetime
#  embargo_duration :string(255)
#

FactoryGirl.define do

  factory :info_request_batch do
    title "Example title"
    user
    body "Some text"
  end

end
