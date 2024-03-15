# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Confirmations' do
  describe 'POST /email_confirmation' do
    subject(:send_email) do
      post '/email_confirmation', params: user_params
    end

    before do
      create(:user, email: 'sms@test.io', confirmed_at: nil)
      send_email
    end

    context 'with valid parameters' do
      let(:user_params) { { user: { email: 'sms@test.io' } } }

      it 'creates a flash message' do
        expect(flash[:notice]).to eq(I18n.t('devise.confirmations.send_instructions'))
      end

      it 'redirects back to the same screen' do
        expect(response).to redirect_to(new_user_confirmation_path)
      end

      it 'returns http see_other status' do
        expect(response).to have_http_status(:see_other)
      end
    end

    context 'with invalid parameters' do
      let(:user_params) { { user: { email: '' } } }

      it 'does not create a flash message' do
        expect(flash[:notice]).to be_nil
      end

      it 'returns http unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /email_confirmation?confirmation_token=abcdef' do
    subject(:confirm_email) do
      get '/email_confirmation', params: user_params
    end

    before { confirm_email }

    context 'when user is unconfirmed' do
      let(:user) { create(:user, email: 'sms@test.io', confirmed_at: nil) }
      let(:user_params) { { confirmation_token: user.confirmation_token } }

      it 'confirms the user' do
        expect(user.reload.confirmed_at).not_to be_nil
      end

      it 'creates a flash message' do
        expect(flash[:notice]).to eq(I18n.t('devise.confirmations.confirmed'))
      end

      it 'redirects to the sign in screen' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'returns http found status' do
        expect(response).to have_http_status(:found)
      end
    end

    context 'when user is already confirmed' do
      let(:user) { create(:user, email: 'sms@test.io', confirmed_at:) }
      let(:user_params) do
        confirmation_token = Devise.friendly_token
        user.update(confirmation_token:)
        { confirmation_token: }
      end
      let(:confirmed_at) { Time.zone.local(2024, 2, 4, 20, 0) }

      it 'confirms the user' do
        expect(user.reload.confirmed_at).to eq(confirmed_at)
      end

      it 'creates a flash message' do
        expect(flash[:alert]).to eq("Email #{I18n.t('errors.messages.already_confirmed')}")
      end

      it 'redirects to the sign in screen' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'returns http found status' do
        expect(response).to have_http_status(:found)
      end
    end
  end
end
