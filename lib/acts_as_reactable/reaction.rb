require "unicode/emoji"

module ActsAsReactable
  class Reaction < ::ActiveRecord::Base
    belongs_to :reactable, polymorphic: true
    belongs_to :reactor, polymorphic: true

    validates_format_of :emoji, with: /\A#{Unicode::Emoji::REGEX.source}\z/
  end
end
