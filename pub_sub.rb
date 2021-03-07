# frozen_string_literal: true

load 'gen_server.rb'
require 'securerandom'

class PubSub
  attr_reader :state

  def self.start
    GenServer.start(PubSub, {}, name: 'PubSub')
  end

  def self.subscribe(ractor, subscriber = Ractor.current, action)
    GenServer.sync(ractor, [:subscribe, subscriber, action])
  end

  def self.unsubscribe(ractor, ref)
    GenServer.async(ractor, [:unsubscribe, ref])
  end

  def self.publish(ractor, action, msg)
    GenServer.async(ractor, [:publish, action, msg])
  end

  def initialize(state)
    @state = state
  end

  def subscribe(ractor, action)
    ref = SecureRandom.hex(10)
    state[[ref, ractor]] = action
    ref
  end

  def unsubscribe(ref)
    actor = state.keys.assoc(ref)
    state.delete(actor)
    nil
  end

  def publish(action, msg)
    state.each do |(_ref, ractor), registered_action|
      next unless action == registered_action

      ractor.send([:event, action, msg])
    end
  end

  def handle(msg)
    p "Unknown message #{msg}"
  end
end

pub_sub = PubSub.start
ref = PubSub.subscribe(pub_sub, :party_time)
PubSub.publish(pub_sub, :party_time, { time: 'Party Time!' })
Ractor.receive_with_timeout(5)

PubSub.unsubscribe(pub_sub, ref)
PubSub.publish(pub_sub, :party_time, { time: 'Party Time!' })
Ractor.receive_with_timeout(5)
