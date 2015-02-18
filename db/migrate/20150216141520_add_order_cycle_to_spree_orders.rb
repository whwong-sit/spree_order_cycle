class AddOrderCycleToSpreeOrders < ActiveRecord::Migration
  def change
    add_reference :spree_orders, :order_cycle, index: true
  end
end
