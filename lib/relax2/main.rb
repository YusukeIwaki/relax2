# frozen_string_literal: true

require 'English'
module Relax2
  require 'relax2/base'

  class MainApplication < Base
  end

  at_exit { MainApplication.run if $ERROR_INFO.nil? }
end

# Forward DSL methods into MainApplication class.
# `extend` is important here for defining DSL only into `main` object.
extend(Module.new do
  Relax2::DSL.instance_methods(false).each do |method_name|
    define_method(method_name) do |*args, **kwargs, &block|
      Relax2::MainApplication.send(method_name, *args, **kwargs, &block)
    end
    private method_name
  end
end)
