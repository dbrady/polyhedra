require 'spec_helper'
require 'polyhedra/dice'

module Polyhedra
  describe Dice do
    context "simple dice expression" do
      let(:dice) { Dice.new("3d6") }

      it { dice.offset.should == 0 }
      it { dice.sides.should == 6 }
      it { dice.number.should == 3 }
      it { dice.roll.should >= 3 }
      it { dice.roll.should <= 18 }
      it { dice.min.should == 3 }
      it { dice.max.should == 18 }
    end

    context "with offset" do
      it { Dice.new("3d6+2").min.should == 5 }
      it { Dice.new("3d6+2").max.should == 20 }
      it { Dice.new("3d6-2").min.should == 1 }
      it { Dice.new("3d6-2").max.should == 16 }
    end

    context "with scalar" do
      it { Dice.new("3d6x10").min.should == 30 }
      it { Dice.new("3d6x10").max.should == 180 }
      it { Dice.new("3d6*10").min.should == 30 }
      it { Dice.new("3d6*10").max.should == 180 }
      it { Dice.new("1d6/2").min.should == 0 }
      it { Dice.new("1d6/2").max.should == 3 }
    end

    context "with reroll_under" do
      let(:dice) { Dice.new("3d6r1") }

      it { dice.reroll_under.should == 1 }
      it { dice.min.should == 6 }
      it { dice.max.should == 18 }
      it { 100.times { dice.roll.should >= 6 }}
    end

    # context "with take_top" do
    #   it { Dice.new("4d6t3").take_top.should == 3 }
    # end

    describe "#pop_expression" do
      describe "returns subexpression, rest_of_string"  do
        it { Dice.new("1d6").pop_expression("r3string").should == ["r", "3", "string"] }
      end
    end
  end
end

