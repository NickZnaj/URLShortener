class ShortenedUrl < ActiveRecord::Base

  validates :short_url, :presence => true, :uniqueness => true
  validates :long_url, length: { maximum: 1024 }

  belongs_to(
    :submitter,
    class_name: 'User',
    foreign_key: :submitter_id,
    primary_key: :id
  )

  has_many(
    :visits,
    class_name: 'Visit',
    foreign_key: :shortened_url_id,
    primary_key: :id
  )

  has_many(
  :viewers,
  -> { distinct },
  through: :visits,
  source: :user
  )

  def self.random_code
    code = nil
    until code && !exists?(code)
      code = SecureRandom.urlsafe_base64
    end
    code
  end

  def self.create_for_user_and_long_url!(user, long_url)
    create!(submitter_id: user.id,
            long_url: long_url,
            short_url: ShortenedUrl.random_code)
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visits.select(:user_id).distinct.count
  end

  def num_recent_uniques
    visits.select(:user_id).where("visits.created_at > '#{10.minutes.ago}'").distinct.count
  end

end
