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
    def_field :name, :description, :url, :author, :author_url, :version, :settings, :directory
    attr_reader :id

    # Plugin constructor
    def self.register(id, &block)
      p = new(id)
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
    #
    # Examples
    #   # Requires Foreman 0.7.3 or higher
    #   requires_foreman :version_or_higher => '0.7.3'
    #   requires_foreman '0.7.3'
    #
    #   # Requires Foreman 0.7.x or higher
    #   requires_foreman '0.7'
    #
    #   # Requires a specific Foreman version
    #   requires_foreman :version => '0.7.3'              # 0.7.3 only
    #   requires_foreman :version => '0.7'                # 0.7.x
    #
    def requires_foreman(arg)
      arg = { :version_or_higher => arg } unless arg.is_a?(Hash)
      arg.assert_valid_keys(:version, :version_or_higher)

      current = SETTINGS[:version].sub('-develop','').split('.')
      arg.each do |k, req|
        case k
        when :version_or_higher
          unless compare_versions(req, current) <= 0
            raise PluginRequirementError.new("#{id} plugin requires Foreman #{req} or higher but current is #{current.join('.')}")
          end
        when :version
          unless compare_versions(req, current) == 0
            raise PluginRequirementError.new("#{id} plugin requires one the following Foreman versions: #{req.join(', ')} but current is #{current.join('.')}")
          end
        end
      end
      true
    end

    def compare_versions(requirement, current)
      requirement = requirement.split('.').collect(&:to_i)
      requirement <=> current.slice(0, requirement.size).collect(&:to_i)
    end
    private :compare_versions

    # Sets a requirement on a Foreman plugin version
    # Raises a PluginRequirementError exception if the requirement is not met
    #
    # Examples
    #   # Requires a plugin named :foo version 0.7.3 or higher
    #   requires_foreman_plugin :foo, :version_or_higher => '0.7.3'
    #   requires_foreman_plugin :foo, '0.7.3'
    #
    #   # Requires a specific version of a Foreman plugin
    #   requires_foreman_plugin :foo, :version => '0.7.3'              # 0.7.3 only
    def requires_foreman_plugin(plugin_name, arg)
      arg = { :version_or_higher => arg } unless arg.is_a?(Hash)
      arg.assert_valid_keys(:version, :version_or_higher)

      plugin = Plugin.find(plugin_name)

      arg.each do |k, req|
        case k
        when :version_or_higher
          unless compare_versions( req, plugin.version ) <= 0
            raise PluginRequirementError.new("#{id} plugin requires the #{plugin_name} plugin #{req} or higher but current is #{plugin.version}")
          end
        when :version
          unless compare_versions( req, plugin.version ) == 0
            raise PluginRequirementError.new("#{id} plugin requires the #{plugin_name} plugin #{req} but current is #{plugin.version}")
          end
        end
      end
      true
    end

    # Adds an item to the given menu
    # The id parameter is automatically added to the url.
    #   menu :menu_name, :plugin_example, 'menu text', { :controller => :example, :action => :index }
    #
    # name parameter can be: :top_menu, :admin_menu
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