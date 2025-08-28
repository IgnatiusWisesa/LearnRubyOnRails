class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def show; end
  def edit; end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Profile updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.profile_user || current_user.build_profile_user
  end

  def profile_params
    params.require(:profile_user).permit(:full_name, :address)
  end

end