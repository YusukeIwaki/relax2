module Relax2
  module DSL
    # @param base_url_value [String]
    def base_url(base_url_value)
      @base_url = base_url_value
    end

    # @param interceptor_impl [Proc]
    def interceptor(interceptor_impl = nil, &interceptor_impl_block)
      if interceptor_impl_block
        (@interceptors ||= []) << interceptor_impl_block
      elsif interceptor_impl
        (@interceptors ||= []) << interceptor_impl
      else
        raise ArgumentError, 'interceptor must be specified as Proc or block'
      end
    end
  end
end
