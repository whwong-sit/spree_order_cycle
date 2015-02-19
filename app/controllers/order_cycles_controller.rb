module Spree
    module Admin
        class OrderCyclesController < ResourceController

        before_action :check_json_authenticity, only: :index
        before_action :load_roles

        def index
            #session[:return_to] = request.url
            #params[:q] ||= {}
            respond_with(@collection) do |format|
                format.html
                format.json { render :json => json_data }
            end
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
