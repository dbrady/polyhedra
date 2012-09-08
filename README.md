# Overview

Polyhedra is a tool to help you write programs that manage dice using
the kinds of expressions most RPG rulebooks use. Some examples of dice
expressions that can be handled:

* d20
* 3d6
* 6d6
* 1d4-1
* 2d6x10
* 2d6*10
* 4d6t3     # roll 4d6, take highest 3
* 3d6r2     # roll 3d6, re-rolling 1's or 2's
* 2d6-1x10  # note that +/- modifiers happen before multipliers; that's just how dice math works. 2d6-1x10 == 1-11x10 == 10-110
* 1d6 fire  # you can assign units to the dice as well

Polyhedra understands dice math:

* 3d6 + 2d6 => 5d6
* 2d6 + 1d4 => 2d6 + 1d4 # dissimilar bases can't be added
* 1d6 fire + 1d4 fire + 1d6 earth => 1d6 + 1d4 fire + 1d6 earth # similar units are grouped before bases

Note that adding two dissimilar dice results in a "DiceSet", which is
a collection of Dice objects. You can still "roll" a DiceSet just like
you would a Dice object, but #sides won't work and #units will return
an array.

Polyhedra also understands units, and knows to avoid adding dice of
different units:

* 3d6 fire + 2d6 physical
* 1d4 frost + 2

# Dice Notation

The simplest RPG Dice notation is given as numbers and letters of the
form _NdS_, where N is the number of dice to roll and S is the number
of sides per die. When you roll all the dice in a Yahtzee cup, you are
rolling 5d6, or five dice, each with six sides. If you are rolling a
single die, you can omit the 1 and represent the notation as e.g d6.

Role-playing games make allowances for other alterations to the roll:
you can add or subtract (2d6+3, 1d4-1), multiply or divide (1d4x10,
1d6/2). (Note that most game systems round down, so 1d6/2 actually
yields a number between 0 and 3.)

Mathematically, none of the following are equivalent: 1d3, 1d4-1,
1d6/2. The first one cannot roll 0's, and although the second two have
the same min/max range, 1d4-1 has an even distribution--exactly a 25%
chance of rolling each number--while 1d6/2 has an uneven distribution
(a 17% chance of rolling a 0, 33% chance of rolling a 1, etc).

## Notational Affixes

* rR - Reroll any dice equal or below R. R must be < S. 3d6r3 will
  roll 12-18 as each die must be 4 or higher to be kept.
  Mathematically 3d6r3 is identical to 3d3+9 but the semantics are
  considered to be different so the extra notation is allowed.

* RR - Reroll any dice equal or above R. R must be > 1 and <= S.

* kM - Keep highest M dice. 1 < M < N. 4d6k3 means roll 4d6, but only
  count the highest 3 dice in the final tally.

* KM - Keep lowest M dice. 1 < M < N.



# Order of Operations

Rerolls are considered first, then keeps. Next--and this is the
reverse of typical algebraic precedence--addition or subtraction
happens and finally multiplication or division. Thus

  4d6r1k3+1x10

Would roll dice until 4 dice showed 2 or higher, then the top 3 dice
would be kept. The range at this point would be 6-18. 1 would be added
to this bumping the range to 7-19. Finally the roll is mulitplied by
10 to yield a range of 70-190. Note that because multiplication is
performed last the final value will be in steps of the multiplier;
e.g. the above dice expression could roll a 70, 80, 90, etc., but
could not roll a 75 or an 81.

# Monkeypatch! Woo! (Fixnum shorthand)

Polyhedra will add .d* methods to Fixnum and to Kernel (d20 is the same
as 1.d20 is the same as Dice.new "1d20"). Since this is a monkeypatch,
it's optional. Require polyhedra/shorthand instead of polyhedra to get
these methods.


    require 'polyhedra/shorthand'
    dice = 3.d6
    # => <#Dice: 3d6>

    fire1 = 1.d6("fire")
    fire2 = 2.d8("fire")
    fire3 = 3.d6(:fire) # symbols and strings are okay
    frost = 2.d6("frost")

    fire1 + fire2 + fire3 + frost
    # => <DiceSet: <Dice: 4d6, fire>, <Dice: 2d8, fire>, <Dice: 2d6 frost>]

Note that while the shorthand allows for modifiers like -1 or x10, it
looks kind of lame.

    1.d6("r1-1")
    # => <Dice: 1d6r1-1>
    2.d10("+3x10")
    # => <Dice: 2d10+3x10>
    d20
    # => <Dice: 1d20>

I am open to changing the interface to cascade like so:

4.d6.r1.k3("+1x10") but honestly this still looks unnecessarily
complicated. Better to just use Dice.new() at this point.

Then again, since we have to catch method_missing to allow for
arbitrary digits, maybe we could steal a page from the Rails playbook
and allow longer methods names that encode the entire sequence, such
as:

    4.d6r1t3
    # => <Dice: 4d6r1t3

The only gotcha is that we can't capture +/- in its proper place
(immediately after the dX sequence). Legal ruby would be `4.d6r1t3+3`
but proper dice notation would `4.d6+3r1t3` which won't work.

Hrm, if a Dice.new() or Fixnum#dXX statement returns a Dice object,
maybe we should define +,-,*,/ etc to return new Dice objects?

    d6
    # => <Dice: 1d6>
    d6 + 1
    # => <Dice: 1d6+1>


## Complex Notation

A set of Dice can be collected into a DiceSet and rolled as a unit:

    bag = DiceSet.new
    bag << Dice.new('3d6')
    bag << '2d4'  # bag#<< accepts Dice or string
    bag
    # => <DiceSet: <Dice: 3d6>, <Dice: 2d4>>
    bag.roll
    # => 19
    bag.max
    # => 26
    bag.min
    # => 5

## Units

Each Dice object can have its own units, and units are treated as a
higher-order grouping than number of sides. Note that #min, #max and
#roll will return an array of pairs containing the amount and unit for
each type of dice.

    bag = DiceSet.new
    bag << 1.d6("fire")
    bag << 1.d6("fire")
    bag << 1.d4("frost")
    bag.min
    # => [[2, :fire], [1, :frost]]
    bag.min_without_units
    # => 3
    bag.max
    # => [[12, :fire], [4, :frost]]
    bag.max_without_units
    # => 16
    bag.roll
    # => [[7, :fire], [2, :frost]]
    bag.roll_without_units
    # => 11

You can also pass a specific unit to #min, #max and #roll to isolate
part of the roll:

    bag.max(:fire)
    # => 12
    bag.min(:frost)
    # => 1
    bag.roll(:fire)
    # => 3


# Contributing

1. Pull requests are welcome!
2. Fork the repo
3. Write _good_ specs for your change: specs that fully cover and
  clearly document the intent of your change
4. Send a pull request

*Note:* If you want to make a wild and crazy change (and have it
  merged into the gem), I'm open to that--but please get in touch with
  me and let's chat about the direction you want to go so you don't
  waste your time (unless you're okay with your changes staying in
  your fork forever)




