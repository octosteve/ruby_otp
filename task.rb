# frozen_string_literal: true
require 'securerandom'

class Add
  def self.call(num1, num2)
    num1 + num2
  end
end

class Task
  attr_reader :ref, :ractor
  def self.async(object, args)
    ref = SecureRandom.uuid.freeze
    ractor = Ractor.new(object, args, ref, Ractor.current) do |object, args, ref, calling_ractor|
      result = object.call(*args)
      calling_ractor.send([:resp, ref, result])
    end
    new(ref, ractor)
  end

  def initialize(ref, ractor)
    @ref = ref
    @ractor = ractor
  end

  def await
    ref = self.ref
    Ractor.receive_if do |msg|
      case msg
      in [:resp, ^ref, resp]
        resp
      else
        false
      end
    end
  end
end

task = Task.async(Add, [1,1])
p task.await
