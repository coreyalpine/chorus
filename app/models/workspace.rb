class Workspace < ActiveRecord::Base
  include SoftDelete
  attr_accessible :name, :public, :summary

  has_attached_file :image, :default_url => "", :styles => {:original => "", :icon => "50x50>"}

  belongs_to :archiver, :class_name => 'User'
  belongs_to :owner, :class_name => 'User'
  has_many :memberships
  has_many :members, :through => :memberships, :source => :user
  has_many :workfiles

  validates_presence_of :name
  validate :owner_is_member, :on => :update

  scope :active, where(:archived_at => nil)

  def self.accessible_to(user)
    with_membership = user.memberships.pluck(:workspace_id)
    where('workspaces.public OR
          workspaces.id IN (:with_membership) OR
          workspaces.owner_id = :user_id',
          :with_membership => with_membership,
          :user_id => user.id
         )
  end

  def self.writable_by(user)
    return scoped if user.admin?
    with_membership = user.memberships.pluck(:workspace_id)
    where('workspaces.id IN (:with_membership) OR
          workspaces.owner_id = :user_id',
          :with_membership => with_membership,
          :user_id => user.id
         ).active
  end

  def members_accessible_to(user)
    if public? || members.include?(user)
      members
    else
      []
    end
  end

  def permissions_for(user)
    permissions = []

    if user.admin? || (owner.id == user.id)
      permissions.push(:admin)
    elsif user.memberships.find_by_workspace_id(id)
      permissions.push(:read, :commenting, :update)
    elsif public?
      permissions.push(:read, :commenting)
    end
    permissions
  end

  def archive_as(user)
    self.archived_at = Time.current
    self.archiver = user
  end

  def unarchive
    self.archived_at = nil
    self.archiver = nil
  end

  private

  def owner_is_member
    unless members.include? owner
      errors.add(:owner, "Owner must be a member")
    end
  end
end
