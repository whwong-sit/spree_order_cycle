Spree::Core::Engine.routes.draw do
    namespace :admin do 
        resources :order_cycles do
            get '/line_items', to: 'order_cycles#line_items'
            get '/pickup_sheet', to: 'order_cycles#pickup_sheet'
        end
    end
end
