class CreateCarShops < ActiveRecord::Migration
  def self.up
    create_table :car_shops do |t|
      t.string :name
      t.string :address
      t.string :tel
      t.string :cate
      t.timestamps
    end
  end

  def self.down
    drop_table :car_shops
  end
end
