# encoding : utf-8
module UsersHelper

  ROLES = { admin: 'Admin', team_leader: 'Team Leader', po: 'PO', user: 'User', qa: 'QA'}

  def role_name(role)
    return ROLES[role.to_sym]
  end

  def can_edit?
    ['team_leader', 'admin'].include?(@current_user.role)
  end

  def base_url
    request.base_url
  end
end
