# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    # To read YARD style documentation from rubocop gem source code
    class Yardoc
      def initialize(cop)
        load_rspec_gems!
        @cop_class = find_cop_class(cop)
        load_yardoc!
      end

      def description
        yardoc.docstring
      end

      def examples
        yardoc.tags('example').map { |tag| [tag.name, tag.text] }
      end

      # Indicates whether the auto-correct a cop does is safe (equivalent) by design.
      # If a cop is unsafe its auto-correct automatically becomes unsafe as well.
      #
      # @return [Boolean]
      def safe_autocorrect?
        config = RuboCop::ConfigLoader.default_configuration
        cop_class.new(config).safe_autocorrect?
      end

      private

      attr_reader :cop_class, :yardoc

      # Loads gems for YARDoc creation
      def load_rspec_gems!
        RSPEC_GEMS.each do |dependency|
          require dependency
        rescue LoadError
          nil
        end
      end

      # Find a RuboCop class by cop name. It find from rubocop/rspec if cannot
      # find any class from rubocop gem.
      #
      # @param cop [String] The target cop name (e.g. "Performance/Size")
      # @return [RuboCop::Cop] Found a RuboCop::Cop class
      def find_cop_class(cop)
        Object.const_get("RuboCop::Cop::#{cop.sub('/', '::')}")
      rescue NameError
        Object.const_get("RuboCop::Cop::RSpec::#{cop.sub('/', '::')}")
      end

      # Loads yardoc from the RuboCop::Cop class file
      def load_yardoc!
        YARD.parse(source_file_path)
        @yardoc = YARD::Registry.all(:class).first
        YARD::Registry.clear
      end

      def instance_methods
        [
          cop_class.instance_methods(false),
          cop_class.private_instance_methods(false)
        ].flatten!
      end

      def source_file_path
        if Object.respond_to?(:const_source_location)
          Object.const_source_location(cop_class.name).first
        else
          instance_methods
            .map { |m| cop_class.instance_method(m).source_location }
            .compact
            .map(&:first)
            .first
        end
      end
    end
  end
end
