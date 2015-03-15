module Spree
    module Admin
        class OrderCyclesController < ResourceController

        before_action :check_json_authenticity, only: :index
        before_action :load_roles

        helper OrderCyclesHelper

        NameField = Struct.new :lastname, :firstname, :email

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
            .where(order_cycle_id: nil)
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
            @oc_line_items = @order_cycle.line_items
            @oc_single_qtys = @order_cycle.single_line_item_qty_breakdown

            respond_to do |format|
                format.html
                format.csv { send_data @order_cycle.to_csv }
                #format.xls { send_data @order_cycle.to_csv(col_sep: "\t") }
                format.xls
            end
        end

        def pickup_sheet
            @order_cycle = Spree::OrderCycle.find(params[:order_cycle_id])
            @name_to_items = @order_cycle.variant_name_to_line_items
            
            respond_to do |format|
                format.html
                format.xls
            end
        end

        def old_pickup_sheet
            @order_cycle = Spree::OrderCycle.find(params[:order_cycle_id])
            @oc_line_items = @order_cycle.line_items

            @user_names = [] 
            @user_to_line_items = {}
            #Eager loading to prevent N+1 queries
            orders = @order_cycle.orders.includes([:ship_address, :line_items])
            
            orders.each do |order|

                lastname = order.ship_address.lastname
                firstname = order.ship_address.firstname

                user = if lastname && firstname 
                    "#{firstname[0].upcase} #{lastname}"
                else
                    order.email
                end

                @user_names << user

                user_oc_line_items = @user_to_line_items[user] || []

                order.line_items.each do |item|
                    var = Spree::Variant.find(item.variant_id)
                    ocl = Spree::OrderCycle::OCLineItem.new(item.variant_id, var.name, var.price, item.quantity, item.total, var.currency)
                    user_oc_line_items << ocl
                end

                @user_to_line_items[user] = user_oc_line_items

            end

            @user_names.sort!.uniq!
            
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
