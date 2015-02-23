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
            attr_accessor :id, :name, :price, :total_price, :currency
            attr_accessor :units, :quantity
            
            def initialize(id, name, price, quantity, total_price, currency)
                @id, @name = id, name
                @currency = currency

                @units = 'each'

                # convert to kg if applicable
                if @name =~ /(\d+)\s*g/  # e.g. 500g
                    #mult = 1/$1.to_i * 1000  # constant to multiply by to get to kg
                    mult = 1000/$1.to_i
                    quantity = quantity.to_f / mult
                    price = price * mult
                    # total price remains the same
                    @units = 'kg'
                end

                @quantity = quantity
                @price = Spree::Money.new price, :currency => currency
                @total_price = Spree::Money.new total_price, :currency => currency
            end

            def variant
                Spree::Variant.find(@id)
            end

            def present_quantity

                # this is a hack to convert things like "500g"x3 to "1.5kg"
                #  this should rightfully be extended in the Spree::Product model
                #  with 'units', 'price per unit', 'min_units'
                #  and with helper views to have converters to coarser scales of the units
                #  e.g.  g -> kg with associated price changes

            end
        end
    end
end
