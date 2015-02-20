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
    end
end
