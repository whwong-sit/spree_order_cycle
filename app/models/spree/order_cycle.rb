module Spree
    class OrderCycle < Spree::Base
        has_many :orders
        has_many :line_items, :through => :orders
            # This grouping and selecting should be done in either the controller or view
            # see http://stackoverflow.com/questions/21531055/rails-has-many-through-grouping-and-summing-data for e.g.
            #-> { group(:variant_id).select(
            #:group => "variant_id, price, currency, cost_price",
            #:select
                #"spree_line_items.variant_id", 
                #"spree_line_items.price", 
                #"spree_line_items.currency", 
                #"spree_line_items.cost_price", 
                #"SUM(spree_line_items.quantity) AS quantity")
                ##I have omitted tax & promo related fields as they  
                ## are specific to individual orders
            #},        
        class OCLineItem
            attr_accessor :id, :name, :price, :quantity, :total_price, :currency
            
            def initialize(id, name, price, quantity, total_price, currency)
                @id, @name = id, name
                @quantity, @currency = quantity, currency
                @price = Spree::Money.new price, :currency => currency
                @total_price = Spree::Money.new total_price, :currency => currency

            end

            def variant
                Spree::Variant.find(@id)
            end
        end
    end
end
