module Polyhedra
  class Dice
    attr_accessor :number, :sides, :offset, :multiplier, :divisor, :reroll_under, :take_top

    def initialize(dice_expression)
      @offset = @reroll_under = 0
      @multiplier = @divisor = 1
      dice_expression.gsub!(/s+/, '')

      @number = dice_expression.to_i
      dice_expression.sub!(/^\d+/, '')

      while dice_expression.length > 0
        action, amount, dice_expression = pop_expression(dice_expression)
        amount = amount.to_i
        case action
        when 'd'
          self.sides = amount
        when '+'
          self.offset = amount
        when '-'
          self.offset = -amount
        when '*', 'x'
          self.multiplier = amount
        when '/'
          self.divisor = amount
        when 'r'
          self.reroll_under = amount
        # when 't'
        #   self.take_top = amount
        end
      end
    end

    def roll
      rolled_dice = []

      while rolled_dice.size < number
        roll=rand(sides)+1
        rolled_dice << roll if roll > reroll_under
      end

      rolled_dice.inject {|a,b| a+b}
    end

    def min
      ((number + offset + (reroll_under*number)) * multiplier) / divisor
    end

    def max
      ((number * sides + offset) * multiplier) / divisor
    end

    def pop_expression(string)
      %r|^([dr+-x\*/])(\d+)(.*)$|.match(string).to_a.dup.tap(&:shift)
    end
  end
end
