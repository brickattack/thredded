class Messageboard < ActiveRecord::Base
  SECURITY = %w{private logged_in public}
  PERMISSIONS = %w{members logged_in anonymous}

  attr_accessible :description,
    :name,
    :posting_permission,
    :security,
    :theme,
    :title

  default_scope where(closed: false).order('topics_count DESC')

  validates_numericality_of :topics_count
  validates_inclusion_of :security, in: SECURITY
  validates_inclusion_of :posting_permission, in: PERMISSIONS
  validates_presence_of :name, :title
  validates_format_of :name, with: /\A[\w\-]+\z/, on: :create,
    message: 'should be letters, nums, dash, underscore only.'
  validates_uniqueness_of :name,
    message: 'must be a unique board name. Try again.', scope: :site_id
  validates_length_of :name, within: 1..16,
    message: 'should be between 1 and 16 characters'

  belongs_to :site
  has_many :categories
  has_many :preferences
  has_many :posts
  has_many :roles
  has_many :topics
  has_many :private_topics
  has_many :users, through: :roles

  def active_users
    sql = <<-SQL
      SELECT u.id,
             u.name,
             u.email
        FROM users u, roles r
       WHERE r.messageboard_id = ?
         AND r.last_seen       > ?
         AND r.user_id         = u.id
       ORDER BY lower(u.name)
    SQL

    User.find_by_sql [sql, self.id, 5.minutes.ago]
  end

  def members_from_list(user_list)
    self.users.where('lower(name) in (?)', user_list.map(&:downcase))
  end

  def postable_by?(user)
    if self.posting_for_anonymous? && (self.restricted_to_private? || self.restricted_to_logged_in?)
        return false
    end
    self.posting_for_anonymous? ||
    (self.posting_for_logged_in? && user.try(:valid?)) ||
    (self.posting_for_members? && user.try(:member_of?, self))
  end

  def posting_for_anonymous?
    'anonymous' == posting_permission
  end

  def posting_for_logged_in?
    'logged_in' == posting_permission
  end

  def posting_for_members?
    'members' == posting_permission
  end

  def public?
    'public' == security
  end

  def restricted_to_logged_in?
    'logged_in' == security
  end

  def restricted_to_private?
    'private' == security
  end

  def to_param
    name.downcase
  end
end
