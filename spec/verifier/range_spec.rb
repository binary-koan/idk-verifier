require "spec_helper"

RSpec.describe Verifier::DefiniteRange do
  let(:range1) { 0..100 }
  let(:range2) { 0..100 }

  let(:value_range1) { Verifier::DefiniteRange.new(range1.begin, range1.end) }
  let(:value_range2) { Verifier::DefiniteRange.new(range2.end, range2.begin) }

  describe "#==" do
    subject { value_range1 == value_range2 }

    context "when the bounds are identical but the range is non-zero" do
      it { is_expected.to eq false }
    end

    context "when the bounds are identical and the range is zero" do
      let(:range1) { 1..1 }
      let(:range2) { 1..1 }
      it { is_expected.to eq true }
    end

    context "when the bounds are different" do
      let(:range1) { 1..2 }
      let(:range2) { 0..1 }
      it { is_expected.to eq false }
    end
  end

  describe "#<" do
    subject { value_range1 < value_range2 }

    context "when the first range is completely below the second one" do
      let(:range1) { 1..5 }
      let(:range2) { 6..10 }
      it { is_expected.to eq true }
    end

    context "when the ranges overlap" do
      let(:range1) { 1..5 }
      let(:range2) { 4..10 }
      it { is_expected.to eq false }
    end
  end

  describe "#>" do
    subject { value_range1 > value_range2 }

    context "when the first range is completely above the second one" do
      let(:range1) { 6..10 }
      let(:range2) { 1..5 }
      it { is_expected.to eq true }
    end

    context "when the ranges overlap" do
      let(:range1) { 4..10 }
      let(:range2) { 1..5 }
      it { is_expected.to eq false }
    end
  end

  describe "#+" do
    subject { (value_range1 + value_range2).to_range }

    context "with two positive ranges" do
      let(:range1) { 1..4 }
      let(:range2) { 2..8 }
      it { is_expected.to eq 3..12 }
    end

    context "with a positive and negative range" do
      let(:range1) { 1..5 }
      let(:range2) { -10..-1 }
      it { is_expected.to eq -9..4 }
    end

    context "with two negative ranges" do
      let(:range1) { -5..-1 }
      let(:range2) { -10..-5 }
      it { is_expected.to eq -15..-6 }
    end
  end

  describe "#-" do
    subject { (value_range1 - value_range2).to_range }

    context "with two positive ranges" do
      let(:range1) { 2..8 }
      let(:range2) { 1..4 }
      it { is_expected.to eq -2..7 }
    end

    context "with a positive and negative range" do
      let(:range1) { 1..5 }
      let(:range2) { -10..-1 }
      it { is_expected.to eq 2..15 }
    end

    context "with two negative ranges" do
      let(:range1) { -5..-1 }
      let(:range2) { -10..-5 }
      it { is_expected.to eq 0..9 }
    end
  end

  describe "#*" do
    subject { (value_range1 * value_range2).to_range }

    context "with two positive ranges" do
      let(:range1) { 1..4 }
      let(:range2) { 2..8 }
      it { is_expected.to eq 2..32 }
    end

    context "with a positive and negative range" do
      let(:range1) { 1..5 }
      let(:range2) { -10..-1 }
      it { is_expected.to eq -50..-1 }
    end

    context "with two negative ranges" do
      let(:range1) { -5..-1 }
      let(:range2) { -10..-5 }
      it { is_expected.to eq 5..50 }
    end
  end

  describe "#/" do
    subject { (value_range1 / value_range2).to_range }

    context "with two positive ranges" do
      let(:range1) { 4..8 }
      let(:range2) { 1..4 }
      it { is_expected.to eq 1..8 }
    end
  end
end
