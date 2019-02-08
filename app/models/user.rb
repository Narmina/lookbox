class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable,
         :omniauth_providers => [:google], :authentication_keys => [:login], :reset_password_keys => [ :login ], :confirmation_keys => [ :login ]

  acts_as_paranoid

  has_many :pictures
  has_many :categories
  has_many :looks

  has_many :user_looks, dependent: :destroy
  has_many :shared_looks, through: :user_looks, source: :look
  has_one :user_setting, :dependent => :destroy

  validates :name, length: {maximum: 25}, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9 \- _]*\z/, message: "invalid name format" }, if: 'name.present?'

  attr_readonly :email
  attr_accessor :login

  def current_user_setting
    user_setting || UserSetting.new(locale: Locale.default_locale, user: self)
  end

  def update_password_with_new(params)
    current_password = params.delete(:current_password)
    if valid_password?(current_password)
      update_attributes(params)
    else
      self.assign_attributes(params)
      self.valid?
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end
  end

  def potential_shared_users
    User.where.not(id: self.id).to_json(only: [:id, :email, :name])
  end

  def self.from_omniauth(auth)
    user = self.find_by_email(auth.info.email)
    if user
      user.uid, user.provider = auth.uid, auth.provider
      user.save if user.changed?
    else
      user_password = SecureRandom.urlsafe_base64(6)
      user = self.create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.name = auth.info.name
        user.password = user_password
        user.skip_confirmation!
      end
      UserMailer.google_user_site_password(user, user_password).deliver_now if user.persisted?
    end
    user
  end

  def self.find_user_by_access_token(access_token)
    User.eager_load(:user_setting => :api_key).where("api_keys.access_token = ? and api_keys.active = ?", access_token, true).first
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["name = :value OR lower(email) = lower(:value)", { :value => login }]).first
    else
      where(conditions).first
    end
  end

end
