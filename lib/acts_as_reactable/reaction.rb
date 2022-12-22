require "unicode/emoji"

module ActsAsReactable
  class Reaction < ::ActiveRecord::Base
    belongs_to :reactable, polymorphic: true
    belongs_to :reactor, polymorphic: true

    # original validation (extended)
    # keeping this for now; can be removed later if problematic
    validates_format_of :emoji, with: /\A#{Unicode::Emoji::REGEX.source}\z/

    # new validations: tracking by emoji id and optional skin tone
    validates :emoji_id, presence: true, inclusion: { in: ActsAsReactable::EMOJI_MART_ALLOWED_IDS, allow_blank: true }
    validates :emoji_skin, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 6, allow_blank: true }
  end
end
