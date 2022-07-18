# frozen_string_literal: true

module Relax2
  NameValuePair = Struct.new(:name, :value) do
    def initialize(...)
      super
      freeze
    end
  end
end
