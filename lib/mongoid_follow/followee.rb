module Mongoid
  module Followee
    extend ActiveSupport::Concern

    included do |base|
      base.field    :fferc, :type => Integer, :default => 0
      base.has_many :followers, :class_name => 'Follow', :as => :followee, :dependent => :destroy
    end

    # know if self is followed by model
    #
    # Example:
    # => @clyde.follower?(@bonnie)
    # => true
    def follower?(model)
      0 < self.followers.find(:all, conditions: {follower_id: model.id}).limit(1).count
    end

    # get followers count
    # Note: this is a cache counter
    #
    # Example:
    # => @bonnie.followers_count
    # => 1
    def followers_count
      self.fferc
    end

    # get followers count by model
    #
    # Example:
    # => @bonnie.followers_count_by_model(User)
    # => 1
    def followers_count_by_model(model)
      self.followers.where(:follower_type => model.to_s).count
    end

    # view all selfs followers
    #
    # Example:
    # => @clyde.all_followers
    # => [@bonnie, @alec]
    def all_followers
      get_followers_of(self)
    end

    # view all selfs followers by model
    #
    # Example:
    # => @clyde.all_followers_by_model
    # => [@bonnie]
    def all_followers_by_model(model)
      get_followers_of(self, model)
    end

    private
    def get_followers_of(me, model = nil)
      followers = !model ? me.followers : me.followers.where(:follower_type => model.to_s)

      followers.collect do |f|
        f.follower
      end
    end

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^(.+)_followers_count$/
        followers_count_by_model($1.camelize)
      elsif missing_method.to_s =~ /^all_(.+)_followers$/
        all_followers_by_model($1.camelize)
      else
        super
      end
    end
  end
end
