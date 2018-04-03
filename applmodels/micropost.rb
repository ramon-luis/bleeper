class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size
  before_save {self.bleepify}

  def bleepify
    bleep = '$%@#-ing'
    min_bleep_size = bleep.length + 1
    words = self.content.split
    word_count = words.length
    char_count = self.content.length
    # one long word with no char space for bleep
    if word_count == 1 && char_count > (140-min_bleep_size)
      words = words
    # 1 word with char space to add bleep
    elsif word_count == 1 && char_count < (140-min_bleep_size)
      words = words.insert(0, bleep)
    # words with char space to add bleep
    elsif char_count< (140-min_bleep_size)
      bleep_index = rand(0..word_count)
      words = words.insert(bleep_index, bleep)
    # all other cases: replace word with bleep
    else
      bleep_index = rand(0..word_count)
      words[bleep_index] = bleep
    end
    self.content = words.join(' ')
  end

  private

    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end

end
