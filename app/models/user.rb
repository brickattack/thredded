class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable

  field :name, :type => String
  field :superadmin, :type => Boolean, :default => false
  references_many :messageboards, :stored_as => :array, :inverse_of => :users
  references_many :roles, :stored_as => :array, :inverse_of => :users
  
  validates_presence_of :name
  validates_uniqueness_of :name, :email, :case_sensitive => false
  attr_accessible :name, :email, :password, :password_confirmation

  # TODO: needs specs
  def superadmin?
    self.superadmin
  end

  # TODO: needs specs
  def admins?(messageboard)
    self.roles.where(:messageboard_id => messageboard.id).any_in(:level => [:admin, :superadmin]).size > 0
  end

end
