# frozen_string_literal: true
module WithTimeout
  def receive_with_timeout(timeout)
    Timeout.timeout(timeout) do
      receive
    end
  rescue Timeout::Error
    :timeout
  end
end
Ractor.extend(WithTimeout)

class GenServer
  def self.start(template_object, state, name:)
    Ractor.new(template_object, state) do |template_object, state|
      state = template_object.new(state)
      loop do
msg = Ractor.receive
        case msg
          in [:sync, :get_state, from]
            from.send(state.state)
          in [:sync, [message, *args], from]
            from.send(state.public_send(message, *args))
          in [:async, [message, *args]]
            state.public_send(message, *args)
          in msg
            state.handle(msg)
        end
      end
    end
  end

  def self.async(ractor, msg)
    ractor.send([:async, msg])
  end

  def self.sync(ractor, msg)
    ractor.send([:sync, msg, Ractor.current])
    Ractor.receive_with_timeout(5)
  end

  def self.get_state(ractor)
    ractor.send([:sync, :get_state, Ractor.current])
    Ractor.receive_with_timeout(5)
  end
end
