module CommentEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_new_comment
  end

  # for both dmp_owners_and_co and institutional reviewers
  # [:dmp_owners_and_co][:new_comment]
  # [:institutional_reviewers][:new_comment]
  def email_new_comment

    #mail all owners and co-owners for a plan that has a new comment
    #if self.comment_type == :owner
      users = self.plan.users
      plan = self.plan
      commenter = self.user
      return true if users.nil? || plan.nil? || commenter.nil?
      users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:new_comment] }
      users.delete_if {|u| !u.id == self.user_id }
      users.each do |user|
        UsersMailer.notification(
            user.email,
            "NEW COMMENT: #{plan.name}",
            "dmp_owners_and_co_new_comment",
            {:comment => self.value, :user => user, :commenter => commenter, :plan => plan } ).deliver
      end
    #end

    #mail All institutional reviewers for plan's institution
    if self.comment_type == :reviewer
      institution = self.user.institution
      users = institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_REVIEWER)
      users.delete_if {|u| !u[:prefs][:institutional_reviewers][:new_comment] }
      users.delete_if {|u| !u.id == self.user_id }
      plan = self.plan
      commenter = self.user
      return true if institution.nil? || plan.nil? || commenter.nil?
      users.each do |user|
        UsersMailer.notification(
            user.email,
            "A new comment was added",
            "institutional_reviewers_new_comment",
            {:comment => self.value, :user => user, :commenter => commenter, :plan => plan } ).deliver
      end
    end
  end
end