class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @editing_profile = params[:edit_profile].present?
    @show_profile_form = @editing_profile || (!current_user.profile_complete? && !session[:profile_form_skipped])
  end

  def update_profile
    if current_user.update(profile_params)
      session.delete(:profile_form_skipped)
      redirect_to root_path, notice: "Your profile information was saved."
    else
      @show_profile_form = true
      render :index, status: :unprocessable_entity
    end
  end

  def skip_profile
    session[:profile_form_skipped] = true
    redirect_to root_path, notice: "You can add your profile information later."
  end

  def soft_delete
    current_user.soft_delete!
    sign_out current_user
    redirect_to new_user_session_path, notice: "Your account has been deleted."
  end

  private

  def profile_params
    params.require(:user).permit(:phone_number, :address, :alternate_email, :avatar)
  end
end
