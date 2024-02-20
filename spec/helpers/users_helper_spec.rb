# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the UserHelper. For example:
#
# describe UserHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe UsersHelper do
  describe '#confirmation_email' do
    context 'with unconfirmed email saved in the cookie' do
      before do
        cookies.encrypted[:unconfirmed_email] = { value: 'test@email.com',
                                                  expires: 1.hour.from_now }
      end

      it 'returns unconfirmed email' do
        expect(helper.confirmation_email).to eq('test@email.com')
      end
    end

    context 'without unconfirmed email cookie' do
      it 'returns expired word' do
        expect(helper.confirmation_email).to eq(I18n.t('user.helpers.confirmation_email_nil'))
      end
    end
  end
end
