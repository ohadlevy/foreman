object @medium

attributes :id, :name, :path
attributes :media_path, :config_path, :image_path, :if => lambda { |medium| medium.os_family == 'Solaris'}
