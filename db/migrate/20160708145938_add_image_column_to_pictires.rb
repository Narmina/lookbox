class AddImageColumnToPictires < ActiveRecord::Migration
  def change
    add_column :pictures, :image, :string
  end
end