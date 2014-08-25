class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE = %w[invite decline accept ignore remove share comment photo_like video_like]
  
  field :message,           type: String
  
  field :data,              type: String
  field :media_id,          type: String
  field :type,              type: String
  field :status,            type: Integer, default: 0

  field :is_read,           type: Boolean, default: false


  belongs_to :user
  scope :unread_notifications, ->{where(is_read:false)}

  after_create :send_mail

  def api_detail
    if self.type == Notification::TYPE[5]
      friend = User.where(id:data).first
      media = Medium.where(id:media_id).first
      info = {
              id:id.to_s,
              date: created_at.strftime("%Y-%m-%d %H:%M:%S"),
              additional:media.present? && media.media_type == "0" ? "2" : "1",
              debug: message,
              friend_time: friend.created_at.strftime("%Y-%m-%d %H:%M:%S"),
              from: friend.name,
              fromEmail: friend.email,
              status: is_read,
              status_info: "Sent notification",
              type: status,
              user_id: friend.id.to_s,
              user_time: user.time,
              media_id:media_id
            }
    else    
      friend = User.where(id:data).first
      info = {
              id:id.to_s,
              date: created_at.strftime("%Y-%m-%d %H:%M:%S"),
              additional:"3",
              debug: message,
              friend_time: friend.created_at,
              from: friend.name,
              fromEmail: friend.email,
              status: is_read,
              status_info: "Sent notification",
              type: status,
              user_id: friend.id.to_s,
              user_time: user.created_at
            }
    end
  end

  def read!
    notification = self
    notification.update_attribute(:is_read, true)
  end

  def send_mail
    case type      
    when Notification::TYPE[0]
      user = self.user
      friend = User.find(data)
      UserMailer.invite_friend(user, friend).deliver
    when Notification::TYPE[1]
      user = self.user
      friend = User.find(data)
      UserMailer.decline_friend(user, friend).deliver
    when Notification::TYPE[2]
      user = self.user
      friend = User.find(data)
      UserMailer.accept_friend(user, friend).deliver
    when Notification::TYPE[3]
      user = self.user
      friend = User.find(data)
      UserMailer.ignore_friend(user, friend).deliver
    when Notification::TYPE[4]
      user = self.user
      friend = User.find(data)
      UserMailer.remove_friend(user, friend).deliver
    end      
  end
end
