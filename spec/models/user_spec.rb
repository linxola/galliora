# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:username) }

    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }

    # Testing format's validation of username field
    it { is_expected.to allow_value('_User.Name-99_').for(:username) }
    it { is_expected.not_to allow_value('a').for(:username) }
    it { is_expected.not_to allow_value('abc$%^&*').for(:username) }
    it { is_expected.not_to allow_value('a' * 33).for(:username) }

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
  end
end
