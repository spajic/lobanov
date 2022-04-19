# frozen_string_literal: true

src = File.expand_path('lobanov/**/*.rb', __dir__)
files = Dir.glob(src).reject { |name| name.end_with?('lobanov/spec_helper.rb') }
files.each { |file| require file }

module Lobanov
  extend Configuration

  class LobanovError < StandardError; end

  class SchemaMismatchError < LobanovError; end

  class NonroutableRequestError < LobanovError; end

  class MissingExampleError < LobanovError; end

  class MissingRequiredFieldError < LobanovError; end

  class MissingNotNullableValueError < LobanovError; end

  class MissingTypeOrExampleError < LobanovError; end

  def self.capture(&block)
    Spy.on(&block)
  end

  def self.capture!(&block)
    Spy.on!(&block)
  end
end
