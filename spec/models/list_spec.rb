require "rails_helper"

RSpec.describe List do
  describe "@name" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(50) }
  end

  describe "@gift_value" do
    it { should validate_numericality_of(:gift_value).is_less_than(10_000)
                                                     .is_greater_than(0) }
    it { should allow_value("", nil).for(:gift_value) }
  end

  describe "@gift_day" do
    it { should validate_presence_of(:gift_day) }

    context "the gift day is set in the past" do
      let!(:list) { FactoryBot.build(:list, gift_day: Date.yesterday) }

      it "should not be valid and give errors" do
        expect(list).to_not be_valid
        expect(list.errors[:gift_day]).to be_present
      end
    end

    context "the gift day is set in the future" do
      let!(:list) { FactoryBot.build(:list, gift_day: Date.tomorrow) }

      it "should be valid" do
        expect(list).to be_valid
      end
    end

    context "the gift day is not set" do
      let!(:list) { FactoryBot.build(:list, gift_day: nil) }

      it "should not be valid and give errors" do
        expect(list).to_not be_valid
        expect(list.errors[:gift_day]).to be_present
      end
    end
  end

  describe "#list_size_limit" do
    subject { size_limited_list }
    let!(:size_limited_list) { FactoryBot.build(:list, santas: santas, limited: limited) }
    let!(:santas) { FactoryBot.build_list(:santa, number) }
    let(:limited) { true } # Default action

    context "where the number of santas is less than 15" do
      let(:number) { 14 }
      it { should be_valid }
    end

    context "where the number of santas is 15" do
      let(:number) { 15 }
      it { should be_valid }
    end

    context "where the number of santas is greater than 15" do
      let(:number) { 16 }
      it { should_not be_valid }
      it "has errors on the object" do
        subject.valid?
        expect(size_limited_list.errors.first).to include "This list is limited to 15 Santas"
      end
    end

    context "where the user has an unlimited list" do
      let(:limited) { false }
      let(:number) { 16 }
      it { should be_valid }
    end

    context "where the user has a limited list" do
      let(:limited) { true }
      let(:number) { 16 }
      it { should_not be_valid}
    end
  end

  describe "@santas" do
    let!(:list) { FactoryBot.create(:list) }
    let!(:santa) { FactoryBot.create(:santa, list_id: list.id) }

    it { should have_many(:santas).inverse_of(:list) }
    it "deletes associated santas if the list is deleted" do
      expect { list.reload.destroy }.to change { Santa.count }.by(-1)
    end
  end

  describe "@cannot_be_changed" do
    let!(:list) { FactoryBot.create(:list, is_locked: status) }
    let!(:santa) { FactoryBot.create(:santa, list_id: list.id) }

    context "where the list is locked" do
      let(:status) { true }

      it "should have errors" do
        expect(list).to_not be_valid
        expect(list.errors[:is_locked]).to be_present
        expect(list.errors.count).to be(1)
        expect(list.errors.first).to include("List has been locked and Santas already emailed.")
      end
    end

    context "where the list is unlocked" do
      let(:status) { false }
      specify { expect(list).to be_valid }
    end
  end
end
