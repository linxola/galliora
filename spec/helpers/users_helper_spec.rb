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
  describe '#confirmations_email_field_value' do
    context 'when user has unconfirmed email' do
      let(:user) { create(:user, unconfirmed_email: 'confirm_me@email.com') }

      it 'returns unconfirmed email' do
        expect(helper.confirmations_email_field_value(user))
          .to eq(user.unconfirmed_email)
      end
    end

    context 'when user has only confirmed email' do
      let(:user) { create(:user, email: 'hello@email.com') }

      it 'returns unconfirmed email' do
        expect(helper.confirmations_email_field_value(user))
          .to eq(user.email)
      end
    end
  end
end
