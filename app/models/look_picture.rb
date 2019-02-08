class LookPicture < ActiveRecord::Base
  belongs_to :look
  belongs_to :picture

  #validates_uniqueness_of :look_id, :scope => :picture_id

  attr_accessor :top, :left, :order, :width, :height
  serialize :position_params, Hash

  def order_number
    position_params[:order] || 1
  end

  def position_order_for_sort
    order.to_i
  end

end