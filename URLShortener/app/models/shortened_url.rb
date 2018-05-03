# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint(8)        not null, primary key
#  short_url  :string           not null
#  long_url   :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedURL < ApplicationRecord
  validates :short_url, presence: true, uniqueness: true
  validates :long_url, :user_id, presence: true

  belongs_to :submitter,
  primary_key: :id,
  foreign_key: :user_id,
  class_name: :User

  has_many :visits,
  primary_key: :id,
  foreign_key: :short_url_id,
  class_name: :Visit

  has_many :visitors,
  -> { distinct }, #lambda literal; functionally = to Proc.new {distict}
  through: :visits,
  source: :user


  def self.generate(user, long_url)
    ShortenedURL.create!({
      user_id: user.id,
      long_url: long_url,
      short_url: ShortenedURL.random_code
      })
  end

  def self.random_code
    code = SecureRandom.urlsafe_base64
    while ShortenedURL.exists?(short_url: code)
      code = SecureRandom.urlsafe_base64
    end
    code
  end

  def num_clicks
    self.visits.length
  end

  def num_uniques
    # Visit.select('visits.user_id')
    # .where('visits.short_url_id = ?', self.id)
    # .distinct
    # .count

    # self.visitors.map { |visitor| visitor.id }.uniq.length
    self.visitors.length
  end

  def num_recent_uniques
    self.visitors
    .where('visits.created_at BETWEEN ? AND ?', 10.minutes.ago, Time.now)
    .count
  end

end
