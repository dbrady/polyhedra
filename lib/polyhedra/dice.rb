module Polyhedra
  class Dice
    attr_accessor :number, :sides, :offset, :multiplier, :divisor

    def initialize(dice_expression)
      @offset = 0
      @multiplier = @divisor = 1
      dice_expression.gsub!(/s+/, '')

      @number = dice_expression.to_i
      dice_expression.sub!(/^\d+/, '')

      while dice_expression.length > 0
        action, amount, dice_expression = pop_expression(dice_expression)
        case action
        when 'd'
          self.sides = amount.to_i
        when '+'
          self.offset = amount.to_i
        when '-'
          self.offset = -amount.to_i
        when '*', 'x'
          self.multiplier = amount.to_i
        when '/'
          self.divisor = amount.to_i
        end
      end
    end

    def roll
      Array.new(number) { rand(sides)+1 }.inject {|a,b| a+b }
    end

    def min
      ((number + offset) * multiplier) / divisor
    end

    def max
      ((number * sides + offset) * multiplier) / divisor
    end

    def pop_expression(string)
      %r|^([dr+-x\*/])(\d+)(.*)$|.match(string).to_a.dup.tap(&:shift)
    end
  end
end
