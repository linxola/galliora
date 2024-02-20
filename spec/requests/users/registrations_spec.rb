# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations' do
  describe 'POST /' do
    subject(:post_create) do
      post '/', params: { user: user_params }
    end

    context 'with valid parameters' do
      let(:user_params) { { username: 'test', email: 'sms@test.io', password: 'testtesttest' } }

      it 'allows to create user with username, email and password' do
        expect { post_create }.to change(User, :count).by(1)
      end

      it 'clears created by devise flash messages' do
        post_create
        expect(flash).to be_empty
      end

      it 'redirects to email confirmation screen' do
        post_create
        expect(response).to redirect_to(new_user_confirmation_path)
      end

      it 'returns http see_other status' do
        post_create
        expect(response).to have_http_status(:see_other)
      end
    end

    context 'with invalid parameters' do
      let(:user_params) { { username: 'test!@#', email: 'sms@test.io', password: 'testtesttest' } }

      it 'allows to create user with username, email and password' do
        expect { post_create }.not_to change(User, :count)
      end

      it 'clears created by devise flash messages' do
        post_create
        expect(flash).to be_empty
      end

      it 'does not redirect' do
        post_create
        expect(response).not_to redirect_to(new_user_confirmation_path)
      end

      it 'returns http unprocessable_entity status' do
        post_create
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
