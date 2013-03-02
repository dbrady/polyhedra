require_relative 'dice'

module DiceStats
  module ClassMethods
    # NOOP
    # kuz we likez eet like dat!!
  end

  module InstanceMethods
    def mean
      0.5 * self.number * ( 1+ self.sides)
    end

    def variance
      ((self.sides ** 2 - 1.0) * self.number) / 12.0
    end

    def std_dev
      self.variance ** 0.5 # the 0.5 power is the sqrt!
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

DiceStats.included(Polyhedra::Dice)
