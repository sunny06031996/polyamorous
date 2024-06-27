# Example modification in polyamorous gem
require 'polyamorous/version'

if defined?(::ActiveRecord)
  module Polyamorous
    # Ensure correct definitions based on ActiveRecord version
    if defined?(Arel::InnerJoin)
      InnerJoin = Arel::InnerJoin
      OuterJoin = Arel::OuterJoin
    else
      InnerJoin = Arel::Nodes::InnerJoin
      OuterJoin = Arel::Nodes::OuterJoin
    end

    # Adjust ActiveRecord class definitions as needed
    if defined?(::ActiveRecord::Associations::JoinDependency)
      JoinDependency  = ::ActiveRecord::Associations::JoinDependency
      JoinAssociation = ::ActiveRecord::Associations::JoinDependency::JoinAssociation
      JoinBase = ::ActiveRecord::Associations::JoinDependency::JoinBase
    else
      JoinDependency  = ::ActiveRecord::Associations::ClassMethods::JoinDependency
      JoinAssociation = ::ActiveRecord::Associations::ClassMethods::JoinDependency::JoinAssociation
      JoinBase = ::ActiveRecord::Associations::ClassMethods::JoinDependency::JoinBase
    end
  end

  # Ensure proper loading of polyamorous files based on ActiveRecord and Ruby versions
  ar_version = ::ActiveRecord::VERSION::STRING[0,3]
  ar_version = '3_and_4.0' if ar_version < '4.1'

  method, ruby_version =
    if RUBY_VERSION >= '2.0' && ar_version >= '4.1'
      [:prepend, '2']
    else
      [:include, '1.9']
    end

  %w(join_association join_dependency).each do |file|
    require "polyamorous/activerecord_#{ar_version}_ruby_#{ruby_version}/#{file}"
  end

  # Apply modifications to ActiveRecord classes
  Polyamorous::JoinDependency.send(method, Polyamorous::JoinDependencyExtensions)
  if method == :prepend
    Polyamorous::JoinDependency.singleton_class
      .send(:prepend, Polyamorous::JoinDependencyExtensions::ClassMethods)
  end
  Polyamorous::JoinAssociation.send(method, Polyamorous::JoinAssociationExtensions)

  Polyamorous::JoinBase.class_eval do
    alias_method :base_klass, :active_record if method_defined?(:active_record)
  end
end
