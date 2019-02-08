module HomeHelper
  def current_user_name
    user_signed_in? && current_user.name.present? ? current_user.name : "friend"
  end

  def introduction_video_link
    ENV['INTRO_VIDEO_ID'].present? ? "https://www.youtube.com/embed/#{ENV['INTRO_VIDEO_ID']}?rel=0&autoplay=0" : ''
  end
end
