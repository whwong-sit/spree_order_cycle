require 'csv'

module Spree
    class OrderCycle < Spree::Base
        has_many :orders
        has_many :line_items, :through => :orders

        alias_method :single_line_items, :line_items

        def to_csv(options = {})
            column_names = %w(Name Price Quantity Units Total)
            CSV.generate(options) do |csv|
                csv <<  column_names
                line_items.each do |line_item|
                    vals = []
                    vals << line_item.name
                    vals << line_item.price.to_s
                    vals << line_item.quantity
                    vals << line_item.units
                    vals << line_item.gross_total.to_s
                    csv << vals
                end
            end
        end

        def line_items
            @line_items ||= self.aggregate_line_items
        end

        class OCLineItem
            attr_accessor :id, :name, :price, :total_price, :currency
            attr_accessor :units, :quantity, :gross_total
            
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
                    #@name = @name.sub /[\s-]*\d+\s*g/, ''
                end

                @quantity = quantity
                @price = Spree::Money.new price, :currency => currency
                @gross_total = Spree::Money.new price*quantity, :currency => currency
                @total_price = Spree::Money.new total_price, :currency => currency
            end

            def variant
                Spree::Variant.find(@id)
            end
        end

        
        def single_line_item_qty_breakdown

            lines = single_line_items
            by_variant = lines.group_by {|item| item.variant_id} 

            single_qty_breakdown = {}

            by_variant.each do |id, items|
                var = Spree::Variant.find(id)
                name = var.name
                qtys = items.map {|x| x.quantity}
                single_qty_breakdown[name] = qtys
            end

            single_qty_breakdown
        end

        def variant_name_to_line_items

            lines = single_line_items
            lines.group_by {|item| item.variant.name } 

        end

        protected

            # Not thread-safe at all 
            # Potential for memoisation
            def aggregate_line_items

                lines = single_line_items
                by_variant = lines.group_by {|item| item.variant_id} 

                ## THIS Part should be made thread safe
                oc_line_items = []

                by_variant.each do |id, items|
                    var = Spree::Variant.find(id)
                    total = items.reduce(0){|tot,x| tot + x.total}
                    qty = items.reduce(0){|tot,x| tot + x.quantity}
                    ocl = Spree::OrderCycle::OCLineItem.new(id, var.name, var.price, qty, total, var.currency)
                    oc_line_items << ocl
                end
                ## END thread-safe part

                oc_line_items.sort! { |a,b| a.name.downcase <=> b.name.downcase }
                oc_line_items
            end
    end
end
