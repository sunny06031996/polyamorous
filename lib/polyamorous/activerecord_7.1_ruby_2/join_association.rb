require 'polyamorous/version'

if defined?(::ActiveRecord)
  module Polyamorous
    if defined?(Arel::InnerJoin)
      InnerJoin = Arel::InnerJoin
      OuterJoin = Arel::OuterJoin
    else
      InnerJoin = Arel::Nodes::InnerJoin
      OuterJoin = Arel::Nodes::OuterJoin
    end

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

  ar_version = ::ActiveRecord::VERSION::STRING[0,3]

  if ar_version >= '7.1'
    ar_version = '7.1'
    ruby_version = '3'
  else
    ar_version = '3_and_4.0'
    ruby_version = RUBY_VERSION >= '2.0' ? '2' : '1.9'
  end

  %w(join_association join_dependency).each do |file|
    begin
      require "polyamorous/activerecord_#{ar_version}_ruby_#{ruby_version}/#{file}"
    rescue LoadError
      raise "Cannot load polyamorous/activerecord_#{ar_version}_ruby_#{ruby_version}/#{file}. Please ensure polyamorous gem version supports ActiveRecord #{ar_version} and Ruby #{ruby_version}."
    end
  end

  if defined?(Polyamorous::JoinDependencyExtensions)
    Polyamorous::JoinDependency.send(:prepend, Polyamorous::JoinDependencyExtensions)
  else
    Polyamorous::JoinDependencyExtensions = Module.new
    Polyamorous::JoinDependency.send(:prepend, Polyamorous::JoinDependencyExtensions)
  end

  if defined?(Polyamorous::JoinAssociationExtensions)
    Polyamorous::JoinAssociation.send(:prepend, Polyamorous::JoinAssociationExtensions)
  else
    Polyamorous::JoinAssociationExtensions = Module.new
    Polyamorous::JoinAssociation.send(:prepend, Polyamorous::JoinAssociationExtensions)
  end

  Polyamorous::JoinBase.class_eval do
    alias_method :base_klass, :active_record if method_defined?(:active_record)
  end
end
