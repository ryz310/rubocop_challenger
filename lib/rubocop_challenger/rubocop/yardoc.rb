# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    # To read YARD style documentation from rubocop gem source code
    class Yardoc
      def initialize(title)
        load_rspec_gems!
        @cop_class = find_cop_class(title)
        YARD.parse(source_file_path)
        @yardoc = YARD::Registry.all(:class).first
        YARD::Registry.clear
      end

      def description
        yardoc.docstring
      end

      def examples
        yardoc.tags('example').map { |tag| [tag.name, tag.text] }
      end

      private

      attr_reader :cop_class, :yardoc

      def load_rspec_gems!
        RSPEC_GEMS.each do |dependency|
          begin
            require dependency
          rescue LoadError
            nil
          end
        end
      end

      # Find a RuboCop class by cop name. It find from rubocop/rspec if cannot
      # find any class from rubocop gem.
      #
      # @param cop_name [String] The target cop name
      # @return [Class] Found RuboCop class
      def find_cop_class(cop_name)
        Object.const_get("RuboCop::Cop::#{cop_name.sub('/', '::')}")
      rescue NameError
        Object.const_get("RuboCop::Cop::RSpec::#{cop_name.sub('/', '::')}")
      end

      def instance_methods
        [
          cop_class.instance_methods(false),
          cop_class.private_instance_methods(false)
        ].flatten!
      end

      def source_file_path
        instance_methods
          .map { |m| cop_class.instance_method(m).source_location }
          .reject(&:nil?)
          .map(&:first)
          .first
      end
    end
  end
end
