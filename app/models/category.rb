class Category < ActiveRecord::Base
  include TheSortableTree::Scopes
  acts_as_nested_set

  belongs_to :user
  has_many :category_pictures
  has_many :pictures, -> { uniq }, :through => :category_pictures

  alias_attribute :title, :name
  accepts_nested_attributes_for :category_pictures
  accepts_nested_attributes_for :pictures

  validates :name, presence: true
  validates_length_of :name, :minimum => 3, :if => proc{|p| p.name.present?}
  validates :user_id, presence: true


  scope :main, -> { where(parent: nil)}
  scope :name_order, -> { reorder('name DESC') }
  scope :created_order, -> { reorder('created_at, name') }

  before_save do |cat|
   cat.user = cat.parent.user if cat.parent.present?
  end

  def move_subcategories
    self.children.each do |cat_child|
      if cat_child.depth > 1
        cat_child.move_to_child_of(cat_child.parent.parent)
      else
        cat_child.move_to_root
      end
    end
    self.reload
  end

end