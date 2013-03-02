require 'spec_helper'
require 'polyhedra/dice'
require 'polyhedra/dice_stats'

module DiceStatsSpec
  describe DiceStats do
    context "getting the mean" do
      it { Polyhedra::Dice.new("3d6").mean.should == 10.5 }
      it { Polyhedra::Dice.new("4d12").mean.should == 26.0 }
      it { Polyhedra::Dice.new("6d3").mean.should == 12.0 }
    end

    context "getting the variance" do
      it { Polyhedra::Dice.new("6d3").variance.should == 4.0 }
      it { Polyhedra::Dice.new("3d6").variance.should == 8.75 }
      it { Polyhedra::Dice.new("6d12").variance.should == 71.5 }
    end

    context "getting the standard deviation" do
      it { Polyhedra::Dice.new("6d3").std_dev.should == 2.0 }
    end

    context "COMBINATIONS!!!!" do
      it { DiceStats::combination(52,5).should == 2_598_960 }
      it { DiceStats::combination(12,3).should == 220 }
    end

    describe "#p_roll_number" do
      let(:dice) { Polyhedra::Dice.new("3d6") }
      it { dice.p_roll_number(2).should == 0 }
      it { dice.p_roll_number(19).should == 0 }
      it { dice.p_roll_number(10).should == 0.125 }
    end

    describe "#p_roll_lt_number" do
      let(:dice) { Polyhedra::Dice.new("3d6") }
      it { dice.p_roll_lt_number(2).should == 0 }
      it { dice.p_roll_lt_number(19).should == 1 }
      it { dice.p_roll_lt_number(10).should be_within(0.00001).of(0.5) }
    end

    describe "#p_roll_gt_number" do
      let(:dice) { Polyhedra::Dice.new("3d6") }
      it { dice.p_roll_gt_number(2).should == 1 }
      it { dice.p_roll_gt_number(19).should == 0 }
      it { dice.p_roll_gt_number(10).should be_within(0.00001).of(0.5) }
    end

  end
end
