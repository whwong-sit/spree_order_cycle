module Spree
    module Admin
        class OrderCyclesController < ResourceController

        before_action :check_json_authenticity, only: :index
        before_action :load_roles

        def index
            respond_with(@collection) do |format|
                format.html
                format.json { render :json => json_data }
            end
        end

        def edit
            @order_cycle = Spree::OrderCycle.find(params[:id])
            cycle_start = @order_cycle.start
            cycle_end = @order_cycle.end
            @pot_orders = Spree::Order.where(:state => 'complete')
                                      .where("completed_at >= ?", cycle_start)
                                      .where("completed_at < ?", cycle_end)

            @ord_search = Spree::Order.ransack(params[:q])
        end

        def create

            #find orders within the order_cycle time range and add them to the cycle
            # if they do not have an assigned order_cycle_id
            #debug(params)
            avail_orders = Spree::Order.where(:state => 'complete')
            .where(order_cycle_id: [false, nil])
            .where("completed_at >= ?", params[:order_cycle][:start])
            .where("completed_at < ?", params[:order_cycle][:end])
            @order_cycle.orders << avail_orders

            super
        end

        def destroy
            order_cycle = Spree::OrderCycle.find(params[:id])
            order_cycle.orders.each {|order| 
                order.order_cycle_id = nil
                order.save
            }
            super
        end

        def model_class
            Spree::OrderCycle
        end

        def line_items
            @order_cycle = Spree::OrderCycle.find(params[:order_cycle_id])
            line_items = @order_cycle.line_items
            by_variant = line_items.group_by {|item| item.variant_id} 

            @oc_line_items = []

            by_variant.each do |id, items|
                var = Spree::Variant.find(id)
                total = items.reduce(0){|tot,x| tot + x.total}
                qty = items.reduce(0){|tot,x| tot + x.quantity}
                ocl = Spree::OrderCycle::OCLineItem.new(id, var.name, var.price, qty, total, var.currency)
                @oc_line_items << ocl
            end

            @oc_line_items.sort! { |a,b| a.name.downcase <=> b.name.downcase }
            
        end

        protected 

            def collection
                return @collection if @collection.present?

                #@search = Spree::OrderCycle.accessible_by(current_ability, :index).ransack(params[:q])
                @search = Spree::OrderCycle.ransack(params[:q])
                @collection = @search.result.page(params[:page]).per(params[:per_page] || Spree::Config[:orders_per_page])
            end

            def load_roles
                @roles = Spree::Role.all
            end
            
        end
    end
end
