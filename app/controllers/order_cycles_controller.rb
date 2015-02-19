module Spree
    module Admin
        class OrderCyclesController < ResourceController

            def index
                session[:return_to] = request.url
                @order_cycles = OrderCycle.all
            end
        end
    end
end

