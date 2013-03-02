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
  end
end
