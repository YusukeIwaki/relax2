module Relax2
  class Response < Struct.new(:status, :headers, :body, keyword_init: true)
    def initialize(...)
      super
      freeze
    end
  end
end
