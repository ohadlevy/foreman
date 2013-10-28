module HomeHelper

  def top_menu_items
    Menu::MenuManager.items(:top_menu).authorized_children
  end

  def admin_menu
    Menu::MenuManager.items(:admin_menu).authorized_children
  end

  def authorized_menu_actions(choices)
    last_item = Menu::MenuDivider.new(:first_div)
    choices = choices.map do |item|
      case item
        when Menu::MenuDivider
          last_item = item unless last_item.is_a?(Menu::MenuDivider) #prevent adjacent dividers
        when Menu::MenuItem
          last_item = item if item.authorized?
        when Menu::MenuToggle
          last_item = item if item.authorized_children.size > 0
      end
    end.compact
    choices.pop if (choices.last.is_a?(Menu::MenuDivider))
    choices
  end

  def menu_item_tag item
    content_tag(:li, link_to(item.caption, item.url_hash), :class => "menu_tab_#{item.url_hash[:controller]} ")
  end

  def org_switcher_title
    title = if Organization.current && Location.current
      Organization.current.to_label + "@" + Location.current.to_label
    elsif Organization.current
      Organization.current.to_label
    elsif Location.current
      Location.current.to_label
    else
      _("Any Context")
    end
    title
  end

  def user_header
    summary = gravatar_image_tag(User.current.mail, :class=>'gravatar small', :alt=>_('Change your avatar at gravatar.com')) +
              "#{User.current.to_label} " + content_tag(:span, "", :class=>'caret')
    link_to(summary.html_safe, "#", :class => "dropdown-toggle", :'data-toggle'=>"dropdown")
  end

end
