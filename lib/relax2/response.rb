# frozen_string_literal: true

module Relax2
  Response = Struct.new(:status, :headers, :body, keyword_init: true) do
    def initialize(...)
      super
      freeze
    end
  end
end
