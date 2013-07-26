module GollumRails

  # Setup functionality for Rails initializer
  #  
  # will be generated by Rails generator: `rails g gollum_rails:install`
  #
  # manually:
  #
  #   GollumRails::Setup.build do |config|
  #     config.repository = '<path_to_your_repository>'
  #     config.wiki = :default
  #     config.startup
  #   end
  #
  # TODO:
  #   * more options
  #
  # FIXME:
  #   currently nothing
  #
  class Setup

    # static baby
    class << self
      

      # Gets / Sets the repository
      attr_accessor :repository

      # Gets / Sets the init options
      attr_accessor :options
      
      # Startup action for building wiki components
      #
      # Returns true or throws an exception if the path is invalid
      def startup=(action)
        if action
          Adapters::Gollum::Connector.enabled = true
          if @repository == :application
            initialize_wiki Rails.application.config.wiki_repository
          else
            initialize_wiki @repository
          end
        end
      end
      
      # Wiki startup options
      def options=(options)
        self.options = options
      end
      
      # defines block builder for Rails initializer.
      # executes public methods inside own class
      #
      def build(&block)
        block.call self
      end

      #######
      private
      #######

      # Checks if provided path is present and valid
      #
      # Example
      #   path_valid? '/'
      #   # =>true
      #  
      #   path_valid? nil
      #   # =>false
      def path_valid?(path)
        return !(path.nil? || path.empty? || ! path.is_a?(String))
      end

      def initialize_wiki(path=nil)
        if path_valid? path
          repository = Grit::Repo.new path.to_s
          GollumRails::Adapters::Gollum::Wiki.new(repository, options)
          true
        else
          raise GollumInternalError, 'no repository path specified'
        end

      end

    end
  end
end
