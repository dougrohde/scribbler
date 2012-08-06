module Scribbler
  class BaseIncluder # I don't love this
    # Wonky way of allowing Base to include the Includeables.
    # Receives require errors with this currently.
    #
    # Examples:
    #
    #   BaseIncluder.include_includeables
    #   # => Nothing
    #
    # Returns Nothing
    # TODO Rework; there must be a more sane way of including these
    def self.include_includeables
      Base.send :include, Scribbler::Includeables
    end
  end

  module Includeables
    extend ActiveSupport::Concern
    module ClassMethods
      def log_location_regex
        /(?<file>.*)_log_location$/
      end

      # Public: defines methods for log location. The first element
      # defines the prefix for the method so "subseason" = subseason_log_location.
      # The second element defines the name of the logfile so "subseason" =
      # root_of_app/log/subseason.log
      #
      # Examples
      #
      #   subseason_log_location
      #   # => #<Pathname:/path_to_ngin/log/subseason_copy_structure.log>
      #
      # Returns Pathname to log
      def method_missing(name, *args, &block)
        (match = name.to_s.match log_location_regex) ? log_at(match[:file]) : super
      end

      def respond_to?(name)
        (m = name.to_s.match log_location_regex) ? !!m : super
      end

      def log_at(file_name)
        File.join Scribbler::Configurator.log_directory, "#{file_name}.log"
      end

      # Public: Save ourselves some repetition. Notifies error to NewRelic
      # and drops given string into a given log.
      #
      # location  - Either a pathname from the above method or symbol for an above
      #             method
      # options   - Hash of options for logging on Ngin
      #           :error     - Error object, mostly for passing to NewRelic
      #           :message   - Message to log in the actual file
      #           :new_relic - Notify NewRelic of the error (default: true)
      #
      # Examples
      #
      #   log(Ngin.subseason_log_location, :error => e, :message  => "Error message stuff", :new_relic => false)
      #
      #   log(:subseason, :error => e, :message => "Error message stuff")
      #
      #   log(:subseason, :message => "Logging like a bauss")
      #
      # Returns Nothing.
      def log(location, options={})
        Scribbler::Base.log(location, options)
      end
    end
  end
end
