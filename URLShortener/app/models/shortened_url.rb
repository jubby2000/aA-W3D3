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

end
