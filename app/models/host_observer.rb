class HostObserver < ActiveRecord::Observer

  def after_validation(host)
    # new server in build mode
    if host.new_record? and host.build?
      host.set_token
    end
    # existing server change build mode
    if host.old and host.build? != host.old.build?
      host.build? ? host.set_token : host.expire_tokens
    end
  end

end
