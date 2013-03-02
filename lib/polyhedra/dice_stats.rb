require_relative 'dice'

module DiceStats
  module ClassMethods

    # eq found at: http://en.wikipedia.org/wiki/Combination#Example_of_counting_combinations
    def combination(n,k)
      lk = ((n-(k-1))..n).to_a.reverse # THE  PARENS MATTER!!!!
      lk.each_with_index.map { |k1, i|
        k1 / (i+1.0)
      }.reduce(1, :*).round # cause combinations are round numbers!
    end  # that was more painful than it should have been...
  end

  module InstanceMethods
    def mean
      0.5 * self.number * ( 1+ self.sides)
    end

    def variance
      ((self.sides ** 2 - 1.0) * self.number) / 12.0
    end

    def std_dev
      Math::sqrt(self.variance)
    end

    # hopefully this won't be as painful as my haskell version was...
    # algo stolen from: http://mathworld.wolfram.com/Dice.html
    # and maybe some: http://en.wikipedia.org/wiki/Dice#Probability
    def p_roll_number(num)
      if num < self.number
        0.0
      elsif num > (self.sides * self.number)
        0.0
      else
        sides, dice = self.sides, self.number # b/c i reference these a lot here
        lk = (0..((num - dice) / sides )).to_a
        (1.0 / sides**dice) * lk.map { |k|
          (-1)**k * DiceStats::combination(dice,k) * DiceStats::combination( (num - sides*k - 1), (dice-1) )
        }.reduce(:+)
      end
    end

    def p_roll_lt_number(num)
      # i know, not quite DRY with above, but you'll live...
      if num < self.number
        0.0
      elsif num > (self.sides * self.number)
        1.0
      else
        num.downto(self.number).map { |n|
          p_roll_number(n)
        }.reduce(:+)  # can you tell i do a lot of functional programming?
      end
    end

    def p_roll_gt_number(num)
      1 - p_roll_lt_number(num)
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

  included(self)
end

DiceStats.included(Polyhedra::Dice)
