module Spree
    class OrderCycle < Spree::Base
        has_many :orders
    end
end
