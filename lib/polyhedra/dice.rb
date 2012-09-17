module Polyhedra
  class Dice
    include Comparable

    attr_accessor :number, :sides, :offset, :multiplier, :divisor, :reroll_under, :take_top
    attr_writer :rng

    def initialize(dice_expression)
      dice_expression = dice_expression.gsub(/s+/, '')

      @offset = @reroll_under = 0
      @multiplier = @divisor = 1

      @take_top = @number = [1, dice_expression.to_i].max
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

    def to_s
      str = ""
      str << "%dd%d" % [number, sides]
      str << "%+d" % offset unless offset.zero?
      str << "x%d" % multiplier unless multiplier == 1
      str << "/%d" % divisor unless divisor == 1
      str << "r%d" % reroll_under unless reroll_under.zero?
      str << "t%d" % take_top unless take_top == number
      str
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

    def inverted_divisor
      1.0 / divisor
    end

    def <=>(other)
      a,b = [:sides, :number, :multiplier, :inverted_divisor, :offset].map {|sym| [send(sym), other.send(sym)] }.detect {|a,b| (a <=> b) != 0 }
      a <=> b
      # if sides != other.sides
      #   sides <=> other.sides
      # else
      #   if number != other.number
      #     number <=> other.number
      #   else
      #     if multiplier != other.multiplier
      #       multiplier <=> other.multiplier
      #     else
      #       -divisor <=> -other.divisor
      #     end
      #   end
      # end
    end

    private
    def rng
      @rng ||= Random.new
    end
  end
end
