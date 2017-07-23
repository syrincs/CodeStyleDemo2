require 'rails_helper'

RSpec.describe Question do
  describe 'validation' do
    it 'pass' do
      question = FactoryGirl.build(:question)
      expect(question).to be_valid
    end

    it 'fails without title' do
      question = FactoryGirl.build(:question, :not_valid_without_title)
      expect(question).not_to be_valid
    end

    it 'fails without description' do
      question = FactoryGirl.build(:question, :not_valid_without_description)
      expect(question).not_to be_valid
    end

    it 'fails' do
      question = FactoryGirl.build(:question, :not_valid)
      expect(question).not_to be_valid
    end
  end
end