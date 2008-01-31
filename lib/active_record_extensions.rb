# module ActiveRecord::Validations::ClassMethods
#   def validates_associated(*associations)
#     associations.each do |association|
#       class_eval do
#         validates_each(associations) do |record, associate_name, value|
#           associate = record.send(associate_name)
#           if associate && !associate.valid?
#             associate.errors.each do |key, value|
#               record.errors.add(key, value)
#             end
#           end
#         end
#       end
#     end
#   end
# end
class ActiveRecord::Base
  # alias_method ‘__initialize__’, ‘initialize’
  # 
  # def initialize options = nil, &block
  #   returning( __initialize__(options, &block) ) do
  #     options ||= {}
  #     options.to_options!
  #     defaults = self.class.defaults || self.defaults || Hash.new 
  #     (defaults.keys - options.keys).each do |key|
  #       value = defaults[key]
  #       case value
  #         when Proc
  #           value = instance_eval &value
  #         when Symbol
  #           value = send value 
  #       end
  #       send “#{ key }=”, value 
  #     end
  #   end
  # end
  # 
  # def self.defaults *argv
  #   @defaults = argv.shift.to_hash if argv.first 
  #   return @defaults if defined? @defaults
  # end
  # 
  # def defaults *argv
  #   @defaults = argv.shift.to_hash if argv.first 
  #   return @defaults if defined? @defaults
  # end
  
  def full_errors
    errors.full_messages.join("\n")
  end
end