class Look < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_many :look_pictures, dependent: :destroy
  has_many :pictures, -> { uniq }, :through => :look_pictures
  accepts_nested_attributes_for :look_pictures

  validates :name, presence: true
  validates_length_of :name, :minimum => 3, :if => proc{|p| p.name.present?}
  validates :user_id, presence: true

end