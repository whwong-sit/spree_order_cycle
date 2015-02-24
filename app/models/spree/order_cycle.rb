module Spree
    class OrderCycle < Spree::Base
        has_many :orders
        has_many :line_items, :through => :orders

        class OCLineItem
            attr_accessor :id, :name, :price, :total_price, :currency
            attr_accessor :units, :quantity
            
            def initialize(id, name, price, quantity, total_price, currency)
                @id, @name = id, name
                @currency = currency

                @units = 'each'

                # this is a hack to convert things like "500g"x3 to "1.5kg"
                #  this should rightfully be extended in the Spree::Product model
                #  with 'units', 'price per unit', 'min_units'
                #  and with helper views to have converters to coarser scales of the units
                #  e.g.  g -> kg with associated price changes
                #
                # convert to kg if applicable
                if @name =~ /(\d+)\s*g/  # e.g. 500g
                    mult = 1000.0/$1.to_f
                    quantity = quantity.to_f / mult
                    price = price * mult
                    # total price remains the same
                    @units = 'kg'
                    @name = @name.sub /[\s-]*\d+\s*g/, ''
               end

                @quantity = quantity
                @price = Spree::Money.new price, :currency => currency
                @total_price = Spree::Money.new total_price, :currency => currency
            end

            def variant
                Spree::Variant.find(@id)
            end

        end
    end
end
