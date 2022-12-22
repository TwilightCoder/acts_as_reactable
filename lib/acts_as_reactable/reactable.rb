# frozen_string_literal: true

module ActsAsReactable
  module Reactable
    def self.included(base)
      base.extend(ClassMethod)
    end

    module ClassMethod
      def acts_as_reactable
        has_many :reactions, class_name: "ActsAsReactable::Reaction", as: :reactable, dependent: :delete_all

        define_method :destroy_reaction_from do |reactor|
          raise "InvalidReactor" if !reactor

          puts reaction = reactions.find_by(reactor: reactor)
          return unless (reaction = reactions.find_by(reactor: reactor))
          reaction.destroy
        end

        define_method :update_reaction_from do |reactor, emoji_attrs = {}|
          raise "InvalidReactor" if !reactor

          if !emoji_attrs.present?
            return destroy_reaction_from(reactor)
          end

          reaction = reactions.where({reactor: reactor, **emoji_attrs}).first_or_create
          reaction
        end

        define_method :add_reactions do |reactor, emoji_attrs_or_list = nil|
          return unless emoji_attrs_or_list

          emoji_attrs_arr = if emoji_attrs_or_list.is_a?(Array)
            emoji_attrs_or_list
          else
            [emoji_attrs_or_list]
          end

          # TODO performance
          # optimize by using a single query
          emoji_attrs_arr
            .each do |emoji_attrs|
              reaction = reactions.find_or_create_by(reactor: reactor, **emoji_attrs)
              reaction.save unless reaction.persisted?
            end

          self
        end

        define_method :remove_reactions do |reactor, emoji_attrs_or_list = nil|
          return unless emoji_attrs_or_list

          if !emoji_attrs_or_list.present?
            return reactions.where(reactor: reactor).destroy_all
          end

          emoji_attr_arr = if emoji_attrs_or_list.is_a?(Array)
            emoji_attrs_or_list
          else
            [emoji_attrs_or_list]
          end

          emoji_attrs_arr
            .each do |emoji_attrs|
              reactions.where(reactor: reactor, **emoji_attrs).destroy_all
            end
          self
        end
      end
    end
  end
end
