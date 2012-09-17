require 'spec_helper'
require 'polyhedra/dice'

# I roll twenties! rand(n) always returns max possible value
class LuckyRng < Random
  def rand(num)
    num-1
  end
end

# Returns 0, 1, 2, ..., n-1 in order.
class GaussianRng < Random
  def rand(num)
    @sequence ||= (0..num).cycle
    @sequence.next
  end
end

# Returns... whatever... you tell... it to...
class JediMindTrickRng < Random
  def initialize(sequence)
    @sequence = sequence.cycle
    super(0)
  end

  def rand(num)
    @sequence.next
  end
end

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
      before(:each) do
        dice.rng = JediMindTrickRng.new [0, 1, 0, 2, 0, 3]
      end
      it { dice.reroll_under.should == 1 }
      it { dice.min.should == 6 }
      it { dice.max.should == 18 }

      it { dice.roll.should == 9 }
    end

    context "with take_top" do
      let(:dice) { Dice.new("4d6t3") }
      it { dice.take_top.should == 3 }
      it { dice.max.should == 18 }
      it { dice.min.should == 3 }
      context "with loaded dice" do
        before :each do
          dice.rng = JediMindTrickRng.new [2,0,4,5]
        end
        it { dice.roll.should == 14 }
      end
    end

    context "when I roll twenties" do
      let(:dice) { Dice.new("4d6") }
      before :each do
        dice.rng = LuckyRng.new
      end
      it { dice.roll.should == 24 }
    end

    describe "#pop_expression" do
      describe "returns subexpression, rest_of_string"  do
        it { Dice.new("1d6").pop_expression("r3string").should == ["r", "3", "string"] }
      end
    end

    describe "#to_s" do
      it { Dice.new("d20").to_s.should == "1d20" }
      it { Dice.new("1d4*10").to_s.should =="1d4x10" }

      # These expressions should all parse and to_s as themselves
      [ "3d6",
        "1d4+1",
        "3d6r1",
        "4d6t3",
        "6d6+3r2t4",
        "1d10x10",
        "1d4+2x10",
        "1d6/2",
        "9d8+2x5r2t6"
      ].each do |str|
        it "correctly parses '#{str}'" do
          Dice.new(str).to_s.should eq str
        end
      end
    end

    describe "comparison" do
      it { Dice.new("3d6").should == Dice.new("3d6") }
      it("favors bases first") { Dice.new("10d4").should < Dice.new("1d5") }
      it("favors number second") { Dice.new("3d6").should > Dice.new("2d6") }
      it("favors multipliers third") { Dice.new("3d6x10").should > Dice.new("3d6x8") }
      it("favors divisors third") { Dice.new("3d6/10").should < Dice.new("3d6/8") }
      it("favors offset fourth") { Dice.new("3d6+3").should > Dice.new("3d6") }
    end

    describe "dice math" do
      describe "addition" do
        it { Dice.new("3d6")}
      end
    end
  end
end

