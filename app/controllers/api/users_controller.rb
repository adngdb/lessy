class Api::UsersController < ApiController
  skip_before_action :require_login, only: [:create]
  skip_before_action :require_tos_accepted, only: %i[create show accept_tos]

  def create
    unless Flipper.enabled? :feature_registration
      errors = [ApiErrors::RegistrationDisabled.new]
      render_errors errors, :forbidden
      return
    end

    @user = User.create!(create_user_params)
    @token = @user.token(1.day.from_now)
    render status: :created
  end

  def show
    @user = current_user
  end

  def accept_tos
    @user = current_user
    @user.update! terms_of_service: TermsOfService.current
  end

private

  def create_user_params
    fetch_resource_params(:user, [:email])
      .merge(terms_of_service: TermsOfService.current)
  end
end
