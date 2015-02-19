Spree::Core::Engine.routes.draw do
    namespace :admin do 
        resources :order_cycles
    end

  # Add your extension routes here
end
