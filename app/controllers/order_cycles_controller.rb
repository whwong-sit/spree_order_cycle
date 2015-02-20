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
            @cy_orders = @order_cycle.orders
            #@orders = Spree::Order.all
            cycle_start = @order_cycle.start
            cycle_end = @order_cycle.end
            @pot_orders = Spree::Order.where(:state => 'complete')
                                      .where("completed_at >= ?", cycle_start)
                                      .where("completed_at < ?", cycle_end)

            @list_items = @order_cycle.line_items
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
            #invoke_callbacks(:create, :before)
            #@object.attributes = permitted_resource_params

            #if @object.save
                #invoke_callbacks(:create, :after)


                #flash[:success] = flash_message_for(@object, :successfully_created)
                #respond_with(@object) do |format|
                    #format.html { redirect_to location_after_save }
                    #format.js   { render :layout => false }
                #end
            #else
                #invoke_callbacks(:create, :fails)
                #respond_with(@object) do |format|
                    #format.html do
                        #flash.now[:error] = @object.errors.full_messages.join(", ")
                        #render action: 'new'
                    #end
                    #format.js { render layout: false }
                #end
            #end
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
