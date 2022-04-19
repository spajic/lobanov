# frozen_string_literal: true

module Lobanov
  class Spy
    def initialize(&block)
      @block = block
      @interactions = []
    end

    def self.on(&block)
      spy = new(&block)
      Thread.current[:lobanov_spy] = spy
      spy.call
    ensure
      Thread.current[:lobanov_spy] = nil
    end

    def self.on!(&block)
      spy = new(&block)
      Thread.current[:lobanov_spy] = spy
      spy.call(overwrite: true)
    ensure
      Thread.current[:lobanov_spy] = nil
    end

    def self.current
      Thread.current[:lobanov_spy]
    end

    def self.enabled?
      current.present?
    end

    def call(overwrite: false)
      @block.call
      Lobanov::HandleCapturedInteractions.call(@interactions, overwrite: overwrite)
    end

    def add_interaction_by_action_dispatch(request, response)
      @interactions << Interaction.from_action_dispatch(request, response)
    end
  end
end
