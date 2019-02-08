class Picture < ActiveRecord::Base
  include CopyCarrierwaveFile
  mount_uploader :image, Rails.application.secrets.use_cloudinary ? CloudinaryUploader : ImageUploader
  crop_uploaded :image
  acts_as_paranoid

  belongs_to :user
  has_many :category_pictures
  has_many :categories, -> { uniq }, :through => :category_pictures
  has_many :look_pictures, dependent: :destroy
  has_many :looks, -> { uniq }, :through => :look_pictures

  attr_accessor :image_encoded, :image_timestamp, :direct_image_url
  serialize :transformation_params, Hash
  store_accessor :transformation_params, :rotation, :crop_x, :crop_y, :crop_w, :crop_h

  validates :title, presence: true
  validates_length_of :title, :minimum => 5, :if => proc{|p| p.title.present?}
  validates :user, presence: true
  validates_with UrlValidator, fields: [:direct_image_url, :link]

  scope :preload_categories, -> { eager_load(:categories) }
  scope :uncategorized, -> { includes(:categories).where( categories: { id: nil } ) }

  # a bit odd, but of many-to-many category and picture
  scope :available_for_category, -> (cat_id) { self.all - includes(:categories).where( categories: { id: cat_id } ) }
  #scope :available_for_look, -> (look_id) { self.all - includes(:looks).where( looks: { id: look_id } ) }

  scope :category_search, -> (include_subcat, *category_ids) do

    any_categories = proc(&:blank?)
    with_included_subcategories = proc{ include_subcat == '1' }
    category_ids_with_children = proc{ |cat_ids| cat_ids.concat(Category.where(id: cat_ids).eager_load(:children).map{|cat| cat.children}.flatten).uniq }

    category_ids.reject!(&:empty?)
    category_ids.delete('0') || category_ids.delete_at(category_ids.index('1') || category_ids.length)
    category_ids.push(nil) if category_ids.delete('-1') # for uncategorized

    case category_ids
      when any_categories
        self.eager_load(:categories)
      when with_included_subcategories
        self.eager_load(:categories).where( categories: { id: category_ids_with_children.call(category_ids) })
      else
        self.eager_load(:categories).where( categories: { id: category_ids })
    end

  end
  
  scope :include_subcategories, -> (include_subcat = nil) { }

  scope :title_description_search, -> (search_text) do
    self.ransack(title_or_description_cont_any: search_text.split).result
  end

  before_save :load_image_from_remote_url, if: ->(obj){ obj.direct_image_url.present? }
  after_update :update_picture
  after_destroy :remove_cloud_image, if: ->(obj){ Rails.application.secrets.use_cloudinary && obj.image.url.present?}

  # whitelist the scope
  def self.ransackable_scopes(auth_object = nil)
    [:category_search, :include_subcategories, :title_description_search]
  end

  def load_image_from_remote_url
    #if valid_direct_url?
      self.remote_image_url = direct_image_url.strip
      self.image = nil
    #end
  end

  def update_picture
    if Rails.application.secrets.use_cloudinary
      previous_image = self.changes.fetch(:image, {}).first
      if previous_image.try(:url) && !self.remote_image_url && !previous_image.try(:filename).eql?(self.image.try(:filename))
        remove_cloud_image(previous_image_public_id(previous_image))
      end
    else
      recreate_image if self.rotation.present?
      create_image_timetamp if self.crop_x.present?
    end
  end

  def duplicate
    Rails.application.secrets.use_cloudinary ? self.make_cloudinary_copy : self.make_carrierwave_copy
  end

  def make_carrierwave_copy
    copy = self.dup
    copy.title += ' copy'
    CopyCarrierwaveFile::CopyFileService.new(self, copy, :image).set_file
    copy.save
    copy
  end

  def make_cloudinary_copy
    copy = Picture.new(self.attributes.except(:image).merge(id: nil, title: "#{self.title} copy"))
    copy.save
    copy.remote_image_url = self.image_url # to save image path with existing picture id
    copy.save
    copy
  end

  #['link', 'direct_image_url'].each { |attribute| define_method(:"#{attribute}=") {|value| super(value.try(:strip))}  }

  def link=(value)
    super(value.try(:strip))
  end

  def possible_categories
    self.categories.map{|cat| cat.self_and_ancestors.ids}.flatten.uniq
  end

  private
  def recreate_image
    image.recreate_versions!
    #create_image_timetamp #for local image storage
  end

  def remove_cloud_image(public_id = self.image.public_id)
    Cloudinary::Uploader.destroy(public_id)
  end

  def previous_image_public_id(previous_image)
    CloudinaryUploader::CLOUD_FOLDER + previous_image.url.split(CloudinaryUploader::CLOUD_FOLDER).last.split('.').first
  end

  def create_image_timetamp
    self.image_timestamp = DateTime.now.to_i
  end

end
