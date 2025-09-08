# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'Validations' do
    it { is_expected.to validate_length_of(:username).is_at_least(2).is_at_most(32) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }

    # Testing format's validation of username field
    it { is_expected.to allow_value('_UserName-99_').for(:username) }
    it { is_expected.to allow_value('user').for(:username) }
    it { is_expected.not_to allow_value('-ab').for(:username) }
    it { is_expected.not_to allow_value('abc$%^&*').for(:username) }

    it { is_expected.to validate_length_of(:name).is_at_most(64).allow_nil }
    it { is_expected.to validate_length_of(:about).is_at_most(256).allow_nil }
  end

  describe 'Class methods' do
    describe '#find_for_database_authentication' do
      let(:searchable_user) { create(:user, username: 'abc', email: 'findme@email.com') }
      let(:other_user) { create(:user, username: 'qwerty', email: 'avoidme@email.com') }

      before do
        searchable_user
        other_user
      end

      it 'finds user with username as login condition' do
        expect(described_class.find_for_database_authentication({ login: 'Abc ' }))
          .to eq(searchable_user)
      end

      it 'finds user with email as login condition' do
        expect(described_class.find_for_database_authentication({ login: 'Findme@email.com ' }))
          .to eq(searchable_user)
      end
    end

    describe '#from_omniauth' do
      let(:oauth_hash) do
        OmniAuth::AuthHash.new({
                                 'provider' => 'github',
                                 'uid' => '12345678',
                                 'info' => {
                                   'nickname' => 'wordi',
                                   'email' => 'hello@email.com',
                                   'name' => 'John Dou',
                                   'image' => '<image_link>'
                                 }
                               })
      end

      context 'when user already exists in the database' do
        let(:user) { create(:user, github_uid: nil, email: 'hello@email.com') }

        before { user }

        it 'does not create new user' do
          expect { described_class.from_omniauth(oauth_hash) }
            .not_to change(described_class, :count)
        end

        it 'returns found user' do
          expect(described_class.from_omniauth(oauth_hash)).to eq(user)
        end

        it 'updates omniauth uid to the found user' do
          described_class.from_omniauth(oauth_hash)
          expect(user.reload.github_uid).to eq('12345678')
        end
      end

      context 'when it is a completely new user' do
        it 'creates new user' do
          expect { described_class.from_omniauth(oauth_hash) }
            .to change(described_class, :count).by(1)
        end

        it 'returns new user' do
          expect(described_class.from_omniauth(oauth_hash)).to eq(described_class.last)
        end

        it 'adds omniauth uid to the new user' do
          described_class.from_omniauth(oauth_hash)
          expect(described_class.last.github_uid).to eq('12345678')
        end
      end

      context 'when it is a new user but omniauth hash is invalid' do
        let(:oauth_hash) do
          OmniAuth::AuthHash.new({
                                   'provider' => 'github',
                                   'uid' => '12345678',
                                   'info' => {
                                     'nickname' => 'A',
                                     'email' => 'hello@email.com',
                                     'name' => 'John Dou',
                                     'image' => '<image_link>'
                                   }
                                 })
        end

        it 'does not create new user' do
          expect { described_class.from_omniauth(oauth_hash) }
            .not_to change(described_class, :count)
        end

        it 'returns unsaved user instance' do
          expect(described_class.from_omniauth(oauth_hash).class).to eq(described_class)
        end
      end
    end

    describe '#create_user_from_oauth' do
      let(:params) do
        OmniAuth::AuthHash.new({
                                 'nickname' => 'wordi',
                                 'email' => 'hello@email.com',
                                 'name' => 'John Dou',
                                 'image' => '<image_link>'
                               })
      end
      let(:expected_user_attributes) do
        {
          'email' => 'hello@email.com',
          'username' => 'wordi',
          'name' => 'John Dou'
        }
      end

      it 'creates new user' do
        expect { described_class.create_user_from_oauth(params) }
          .to change(described_class, :count).by(1)
      end

      it 'creates user with necessary attributes' do
        described_class.create_user_from_oauth(params)
        expect(described_class.last.attributes).to include(expected_user_attributes)
      end

      it 'confirms new user' do
        described_class.create_user_from_oauth(params)
        expect(described_class.last).to be_confirmed
      end

      it 'returns new user' do
        expect(described_class.create_user_from_oauth(params)).to eq(described_class.last)
      end

      context 'when params hash is invalid' do
        let(:params) do
          OmniAuth::AuthHash.new({
                                   'nickname' => 'A',
                                   'email' => 'hello@email.com',
                                   'name' => 'John Dou',
                                   'image' => '<image_link>'
                                 })
        end

        it 'does not create new user' do
          expect { described_class.create_user_from_oauth(params) }
            .not_to change(described_class, :count)
        end

        it 'returns unsaved user instance' do
          expect(described_class.create_user_from_oauth(params).class).to eq(described_class)
        end
      end
    end

    describe '#create_username_from_oauth' do
      context 'when there is a username and it is not present in the DB' do
        it 'returns passed username' do
          expect(described_class.create_username_from_oauth('wordi', 'hello@email.com'))
            .to eq('wordi')
        end
      end

      context 'when username is nil, but email part before @ is not present in the DB' do
        it 'returns username created form email' do
          expect(described_class.create_username_from_oauth(nil, 'hello@email.com'))
            .to eq('hello')
        end
      end

      context 'when username is already present in the DB, but email part before @ is not' do
        let(:user) { create(:user, username: 'wordi', email: 'wordi@email.com') }

        it 'returns username created form email' do
          user
          expect(described_class.create_username_from_oauth('wordi', 'hello@email.com'))
            .to eq('hello')
        end
      end

      context 'when username is nil or already present in the DB, along with email part before @' do
        let(:taken_email) { create(:user, username: 'hello', email: 'hello@email.com') }
        let(:taken_username) { create(:user, username: 'wordi', email: 'wordi@email.com') }

        it 'returns username created form email, but with random digits added' do
          taken_email
          taken_username
          expect(described_class.create_username_from_oauth('wordi', 'hello@email.com'))
            .to match(/\Ahello\d+\z/)
        end
      end
    end

    describe '#set_oauth_uid' do
      context 'when GitHub is provider' do
        context 'when GitHub was not connected to the account before' do
          let(:user) { create(:user, github_uid: nil) }

          it 'sets GitHub uid' do
            described_class.set_oauth_uid(user, 'github', '12345678')
            expect(user.reload.github_uid).to eq('12345678')
          end
        end

        context 'when GitHub was connected to the account before' do
          let(:user) { create(:user, github_uid: '87654321') }

          it 'does not change GitHub uid' do
            described_class.set_oauth_uid(user, 'github', '12345678')
            expect(user.reload.github_uid).to eq('87654321')
          end
        end
      end

      context 'when Google is provider' do
        context 'when Google was not connected to the account before' do
          let(:user) { create(:user, google_uid: nil) }

          it 'sets Google uid' do
            described_class.set_oauth_uid(user, 'google_oauth2', '12345678')
            expect(user.reload.google_uid).to eq('12345678')
          end
        end

        context 'when Google was connected to the account before' do
          let(:user) { create(:user, google_uid: '87654321') }

          it 'does not change Google uid' do
            described_class.set_oauth_uid(user, 'google_oauth2', '12345678')
            expect(user.reload.google_uid).to eq('87654321')
          end
        end
      end
    end
  end
end
