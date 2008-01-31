module ActiveRecordMatchers
  class HaveValidAssociations
    def matches?(model)
      @failed_association = nil
      @model_class = model.class
      
      model.class.reflect_on_all_associations.each do |assoc|
        model.send(assoc.name, true) rescue @failed_association = assoc.name
      end
      !@failed_association
    end
  
    def failure_message
      "invalid association \"#{@failed_association}\" on #{@model_class}"
    end
  end

  def have_valid_associations
    HaveValidAssociations.new
  end
end

module CustomMatchers
  
  class BeValidWith
    def initialize(attribute, *values)
      @options = values.extract_options!
      @attribute = attribute
      @values = values.flatten
    end

    def matches?(model)
      @model = model
      @failed_value = nil
      @passed_value = nil
      @values.each do |value|
        attrs = @options[:confirm] ? {@attribute.to_sym => value, :"#{@attribute.to_s}_confirmation" => value} : {@attribute.to_sym => value}
        
        begin
          @model.update_attributes!(attrs)
          @passed_value = value
        rescue
          @failed_value = value
        end
      end
      caller[1] =~ /should_not/ ? @passed_value : !@failed_value
      # If we are called from "should_not" then no values should have passed, so
      # we return a true if @passed_value is still nil (and false if something passed!).
      # Otherwise this must be a "should" so nothing should have failed and we return
      # a true only if @failed_value is still nil.
    end

    def failure_message
      "expected #{@model.class} to be valid for attribute #{@attribute.inspect} = #{@failed_value.inspect}"
    end

    def negative_failure_message
      "expected #{@model.class} not to be valid for attribute #{@attribute.inspect} = #{@passed_value.inspect}"
    end
  end

  def be_valid_with(attribute, *values)
    BeValidWith.new(attribute, *values)
  end

  class AllowBlank
    def initialize(attribute)
      @attribute = attribute
    end

    # Checks to see if model is valid with attribute set to empty string or nil
    def matches?(model)
      @model = model
      @model[@attribute] = ''
      valid = @model.valid?
      @model[@attribute] = nil
      valid && @model.valid?
    end

    def failure_message
      "expected #{@model.class} to be valid for attribute #{@attribute.inspect} nil or blank"
    end

    def negative_failure_message
      "expected #{@model.class} not to be valid for attribute #{@attribute.inspect} nil or blank"
    end
  end

  def allow_blank(attribute)
    AllowBlank.new(attribute)
  end
  
  def be_family_with(member)
    return simple_matcher("to be family with #{member.to_s}") do |actual|
      actual.family_member?(member)
    end
  end
  
  def be_in(expected)
    return simple_matcher("to be in #{expected.inspect}") do |actual|
      actual.include?(expected)
    end
  end
  
  def update_attributes(attributes)
    return simple_matcher("#{attributes.inspect} puts your object in an invalid state") do |model|
      model.update_attributes(attributes)
    end
  end
end

module Spec
    module Matchers
      class MatchXpath  #:nodoc:
        
        def initialize(xpath)
          @xpath = xpath
        end

        def matches?(response)
          @response_text = response.body
          doc = Hpricot.XML(@response_text)
          match = doc/@xpath
          not match.empty?
        end

        def failure_message
          "Did not find expected xpath #{@xpath}\n" + 
          "Response text was #{@response_text}"
        end

        def description
          "match the xpath expression #{@xpath}"
        end
      end

      def match_xpath(xpath)
        MatchXpath.new(xpath)
      end      
    end
end
