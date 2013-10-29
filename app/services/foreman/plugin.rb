# Redmine - project management software
# Copyright (C) 2006-2013  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module Foreman #:nodoc:

  class PluginNotFound < StandardError; end
  class PluginRequirementError < StandardError; end

  # Base class for Foreman plugins.
  # Plugins are registered using the <tt>register</tt> class method that acts as the public constructor.
  #
  #   Foreman::Plugin.register :example do
  #     name 'Example plugin'
  #     author 'John Smith'
  #     description 'This is an example plugin for Foreman'
  #     version '0.0.1'
  #   end
  #
  class Plugin

    @registered_plugins = {}
    class << self
      attr_reader :registered_plugins
      private :new

      def def_field(*names)
        class_eval do
          names.each do |name|
            define_method(name) do |*args|
              args.empty? ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", *args)
            end
          end
        end
      end
    end
    def_field :name, :description, :url, :author, :author_url, :version
    attr_reader :id

    # Plugin constructor
    def self.register(id, &block)
      p = new(id)
      if (gem = Gem::Specification.find_by_name(id.to_s))
      p.name gem.name
      p.author  gem.authors.join(',')
      p.description gem.description
      p.url gem.homepage
      p.version  gem.version
      end
      p.instance_eval(&block)

      registered_plugins[id] = p
    end

    # Returns an array of all registered plugins
    def self.all
      registered_plugins.values.sort
    end

    # Finds a plugin by its id
    # Returns a PluginNotFound exception if the plugin doesn't exist
    def self.find(id)
      registered_plugins[id.to_sym] || raise(PluginNotFound)
    end

    # Checks if a plugin is installed
    #
    # @param [String] id name of the plugin
    def self.installed?(id)
      registered_plugins[id.to_sym].present?
    end

    def initialize(id)
      @id = id.to_sym
    end


    def to_param
      id
    end

    def <=>(plugin)
      self.id.to_s <=> plugin.id.to_s
    end

    # Sets a requirement on Foreman version
    # Raises a PluginRequirementError exception if the requirement is not met
    # matcher format is gem dependency format
    def requires_foreman(matcher)
      current = SETTINGS[:version].gsub('-','.')
      unless Gem::Dependency.new(nil, matcher).match?(nil, current)
        raise PluginRequirementError.new("#{id} plugin requires Foreman #{matcher} but current is #{current}")
      end
    end

    # Sets a requirement on a Foreman plugin version
    # Raises a PluginRequirementError exception if the requirement is not met
    # matcher format is gem dependency format
    def requires_foreman_plugin(plugin_name, matcher)
      plugin = Plugin.find(plugin_name)
      raise PluginRequirementError.new("#{id} plugin requires the #{plugin_name} plugin, not found") unless plugin
      unless Gem::Dependency.new(nil, matcher).match?(nil, plugin.version)
        raise PluginRequirementError.new("#{id} plugin requires the #{plugin_name} plugin #{matcher} but current is #{plugin.version}")
      end
    end

    # Adds an item to the given menu
    # The id parameter is automatically added to the url.
    #   menu :menu_name, :plugin_example, 'menu text', { :controller => :example, :action => :index }
    #
    # name parameter can be: :top_menu or :admin_menu
    #
    def menu(menu, name, options={})
      options.merge!(:parent => @parent) if @parent
      Menu::MenuManager.map(menu).item(name, options)
    end
    alias :add_menu_item :menu

    def sub_menu(menu, name, options={}, &block)
      options.merge!(:parent => @parent) if @parent
      Menu::MenuManager.map(menu).sub_menu(name, options)
      current = @parent
      @parent = name
      self.instance_eval(&block)
      @parent = current
    end

    # Removes item from the given menu
    def delete_menu_item(menu, item)
      Menu::MenuManager.map(menu).delete(item)
    end

    def security_block(name, &block)
      @security_block = name
      self.instance_eval(&block)
      @security_block = nil
    end

    # Defines a permission called name for the given controller=>actions
    def permission(name, hash, options={})
      options.merge!(:security_block => @security_block)
      Foreman::AccessControl.map do |map|
          map.permission name, hash, options
      end
    end

    # Add a new role if it doesn't exist
    def role(name, permissions)
      Role.transaction do
        role = Role.find_or_create_by_name(name)
        role.update_attribute :permissions, permissions if role.permissions.empty?
      end
      rescue
    end

  end
end