# frozen_string_literal: true

module Relax2
  module DSL
    # @param base_url_value [String]
    def base_url(base_url_value)
      @base_url = base_url_value
    end

    # @param interceptor_impl [Proc|Symbol]
    def interceptor(interceptor_impl = nil, &interceptor_impl_block)
      impl =
        if interceptor_impl_block
          interceptor_impl_block
        elsif interceptor_impl.is_a?(Symbol)
          ::Relax2::Interceptors.send(interceptor_impl)
        elsif interceptor_impl.respond_to?(:call)
          interceptor_impl
        else
          raise ArgumentError, 'interceptor must be specified as Proc or block'
        end
      (@interceptors ||= []) << impl
    end
  end
end
