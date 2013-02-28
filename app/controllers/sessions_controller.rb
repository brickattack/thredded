class SessionsController < Devise::SessionsController
  def create
    if env.key? 'omniauth.auth'
      identity = Identity.from_omniauth( env['omniauth.auth'] )
      sign_in identity.user
      session[:signed_in_with] = env['omniauth.auth']['provider']
      notice = <<-EOC.strip_heredoc.html_safe
        You have logged in with an external service like GitHub, Facebook or
        Twitter and might have an account here already. If you would like to
        link your external service's identity with your existing account, then
        <a href='/users/edit'>visit your account page</a>.
      EOC

      redirect_to home_or_origin_path, flash: { notice: notice }
    else
      if params['after_sign_in_redirect']
        session[:redirect_url] = params['after_sign_in_redirect']
      end

      super
    end
  end

  private

  def home_or_origin_path
    if request.env['omniauth.origin'].include? 'users/sign_in'
      root_path
    else
      request.env['omniauth.origin']
    end
  end
end
