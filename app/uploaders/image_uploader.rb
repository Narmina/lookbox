# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  include CarrierWave::ImageOptimizer

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{Rails.env.test? ? 'test/' : ''}#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "uploads/#{Rails.env.test? ? 'test/' : ''}tmp"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # process :auto_orient # this should go before all other "process" steps
  #
  # def auto_orient
  #   manipulate! do |image|
  #     image.tap(&:auto_orient)
  #   end
  # end

  process optimize: [{ quality: 80 }]
  process :crop

  def rotate_img
    manipulate! do |img|
      img.rotate(model.rotation)
      img #returns the manipulated image
    end
  end

  def has_rotation?(opt)
    model.rotation.present? && model.rotation.to_i > 0
  end

  process :rotate_img, if: :has_rotation?

  # Create different versions of your uploaded files:

  version :large do
    process :resize_to_limit => [600, 10000]
  end

  version :thumb do
    process :resize_to_fill => [150, 150]
  end

  def crop
    if model.crop_x.to_f > 0 || model.crop_y.to_f > 0
      manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop("#{w}x#{h}+#{x}+#{y}")
        img
      end
    end
  end

  # def public_id
  #   "#{model.class.to_s.underscore}-#{mounted_as}-#{model.id}"
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  # "something.jpg" if original_filename
  # end

end
