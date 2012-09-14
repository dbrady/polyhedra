module Polyhedra
  class Dice
    attr_accessor :number, :sides, :offset, :multiplier, :divisor, :reroll_under, :take_top
    attr_writer :rng

    def initialize(dice_expression)
      @offset = @reroll_under = 0
      @multiplier = @divisor = 1
      dice_expression.gsub!(/s+/, '')

      @take_top = @number = dice_expression.to_i
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
        when 't'
          self.take_top = amount
        end
      end
    end

    def roll
      rolled_dice = []

      while rolled_dice.size < number
        roll=rand(sides)+1
        rolled_dice << roll if roll > reroll_under
      end

      rolled_dice = rolled_dice.sort.reverse.take take_top

      rolled_dice.inject {|a,b| a+b}
    end

    def min
      ((take_top + offset + (reroll_under*take_top)) * multiplier) / divisor
    end

    def max
      ((take_top * sides + offset) * multiplier) / divisor
    end

    def pop_expression(string)
      %r|^([dr+-x\*/])(\d+)(.*)$|.match(string).to_a.dup.tap(&:shift)
    end

    # def dice_matrix
    #   # TODO: make this work with take_top--probably a sort/take in the each_slice?
    #   # TODO: make this work with reroll--probably change the 1..sides to reroll+1..sides ?
    #   Array.new(number) { (1..sides).to_a }.inject(:product).flatten.each_slice(number).map {|ray| ray.sort.take take_top }
    # end

    def rand(num)
      rng.rand(num)
    end

    private
    def rng
      @rng ||= Random.new
    end
  end
end
