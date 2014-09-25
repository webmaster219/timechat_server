class Like
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :media, class_name: 'Medium'

  # after_create :send_notification

  def api_detail
    {
      id:id.to_s,
      avatar:self.user.avatar.url,
      create_time:created_at.strftime("%Y-%m-%d %H:%M:%S"),
      user_id:self.user.id.to_s,
      user_name:self.user.name
    }
  end

  def send_notification
    media_user = media.user
    unless user == media_user
      media_user.send_notification_like_your_photo(user, media.media_type) 
      media_user.send_push_notification("#{user.name} favorited your photo")
    end    
  end

end
