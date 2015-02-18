class CreateOrderCycles < ActiveRecord::Migration
  def change
    create_table :spree_order_cycles do |t|
      t.string :name
      t.datetime :start
      t.datetime :end

      t.timestamps
    end
  end
end
