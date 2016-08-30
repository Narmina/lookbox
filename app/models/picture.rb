class Picture < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  acts_as_paranoid

  belongs_to :user
  has_many :category_pictures
  has_many :categories, -> { uniq }, :through => :category_pictures

  cattr_accessor(:with_subcategories) { false }

  validates :title, presence: true
  validates_length_of :title, :minimum => 5, :if => proc{|p| p.title.present?}
  validates :user, presence: true

  scope :uncategorized, -> { includes(:categories).where( categories: { id: nil } ) }

  # a bit odd, but of many-to-many category and picture
  scope :available_for_category, -> (cat_id) { self.all - includes(:categories).where( categories: { id: cat_id } ) }

  scope :category_search, -> (category_id = -1) do
    ids = category_id.to_i < 1 ? nil : category_id
    ids = Category.find(category_id).self_and_descendants.ids if self.with_subcategories
    includes(:categories).where( categories: { id: ids })
  end
  scope :include_subcategories, -> {}

  # whitelist the scope
  def self.ransackable_scopes(auth_object = nil)
    [:category_search, :include_subcategories]
  end


end
