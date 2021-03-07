# frozen_string_literal: true

require_relative 'gen_server'

class Counter
  attr_reader :state

  def self.add(ractor, inc = 1)
    GenServer.async(ractor, [:add, inc])
  end

  def self.subtract(ractor, dec = 1)
    GenServer.async(ractor, [:subtract, dec])
  end

  def self.get_state(ractor)
    GenServer.get_state(ractor)
  end

  def initialize(state)
    @state = state
  end

  def add(inc = 1)
    @state += inc
  end

  def subtract(dec = 1)
    @state -= dec
  end

  def handle(msg)
    p "Unknown message #{msg}"
  end
end

counter = GenServer.start(Counter, 1, name: 'Counter')
Counter.add(counter)
Counter.add(counter)
Counter.add(counter)
Counter.get_state(counter)

require_relative 'gen_server'
