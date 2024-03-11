# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Passwords' do
  describe 'POST /password' do
    subject(:post_reset_password) do
      post '/password', params: user_params
    end

    before { create(:user, email: 'sms@test.io') }

    context 'with valid parameters' do
      let(:user_params) { { user: { email: 'sms@test.io' } } }

      before { post_reset_password }

      it 'creates a flash message' do
        expect(flash[:notice]).to eq(I18n.t('devise.passwords.send_instructions'))
      end

      it 'redirects back to the same screen' do
        expect(response).to redirect_to(new_user_password_path)
      end

      it 'returns http see_other status' do
        expect(response).to have_http_status(:see_other)
      end
    end

    context 'with invalid parameters' do
      let(:user_params) { { user: { email: '' } } }

      before { post_reset_password }

      it 'does not create a flash message' do
        expect(flash[:notice]).to be_nil
      end

      it 'returns http unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
