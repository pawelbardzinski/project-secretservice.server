class User < ActiveRecord::Base
  validate :is_valid_password, if: lambda{ new_record? || !password.nil? }
  belongs_to :venue
  has_many :order, dependent: :destroy
  has_many :payment_option, dependent: :destroy

  validates :firstname, presence: true
  validates :role, presence: true

  validates :mobile, presence: true, if: :is_mobile_required
  validates :mobile, format: { with: /^(?:\([2-9]\d{2}\)\ ?|[2-9]\d{2}(?:\-?|\ ?))[2-9]\d{2}[- ]?\d{4}$/,
                                              multiline:true,
                                              message: "is invalid" }, if: :mobile?

  validates :email, uniqueness: { case_sensitive: false }, presence: true
  validates :email, format: {with: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/,
                                                               multiline:true,
                                                               message: "is invalid." }, if: :email?

  before_validation :set_auth_token,:set_role,:format_mobile

  has_secure_password


  ROLES = {
      :customer => {:id => 1, :name => "customer", :label => "Customer"},
      :waiter => {:id => 2, :name => "waiter", :label => "Waiter"},
      :venue_admin => {:id => 4, :name => "venueadmin", :label => "Venue Admin"},
      :admin => {:id => 8, :name => "admin", :label => "Admin"}
  }

  def self.authenticate(email, password)
    user = find_by(email: email)
    user && !user.archived && user.authenticate(password)
  end

  def clear_auth_token
    self.auth_token=nil
    self.token_expiration=Time.now
  end

  # Exclude password info from xml output.
  def to_xml(options={})
    options[:except] ||= :password_digest
    super(options)
  end

  # Exclude password info from json output.
  def to_json(options={})
    options[:except] ||= :password_digest
    super(options)
  end

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

  def is_in_role(role_id)
    (self.role & role_id) > 0
  end
  private

  def set_auth_token
    return if auth_token.present?
    self.auth_token = generate_auth_token
    self.token_expiration = DateTime.current.advance(year:0,months:1) unless token_expiration.present?
  end

  def set_role
    self.role = User::ROLES[:customer][:id] unless self.role or self.role == 0
  end

  def generate_auth_token
    loop do
      token = SecureRandom.hex
      break token unless self.class.exists?(auth_token: token)
    end
  end

  def format_mobile
    self.mobile = User.format_mobile(self.mobile) if self.mobile
  end

  def is_mobile_required
    self.role == User::ROLES[:customer][:id]
  end

  def is_valid_password
    unless self.password and self.password.length>5
      errors[:password] << 'is too short (minimum is 6 characters)'
    end

  end

  def self.format_mobile(mobile)
    mobile.gsub(/[.\-()\W]/, '')
  end

end
