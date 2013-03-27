module GollumRails
  module Adapters
    module ActiveModel

      # General Validation Class including validations
      class Validation
        include ::ActiveModel::Validations

        # Gets/Sets the variable, used to validate
        attr_accessor :variable

        # Filter
        attr_accessor :filter

        # Checks for errors and returns either true or false
        #
        # Examples:
        #   @validator.valid?
        #   # => true
        #   or 
        #   # => false
        #
        def valid?
          return true if not self.errors.messages != Hash.new
          return false
        end

        # Initializes the Validator
        # You can pass in a block with validators, which will be used to validate given attributes
        # 
        # Blocks look like:
        #
        # "#{variable} : type=String : max=200"
        # "#{textvariable} : type=Hash"
        # "#{integer} : min=100 : max=200"
        #
        # They have always the following format:
        #   
        #   KEY=VALUE or KEY!VALUE
        #
        #   key=value explains itself. It validates the variable <b>variable</b> with the given <b>key<b> validator
        #   and checks if it matches the given <b>value</b>
        #
        #   key!value is the negociation of key=value
        #
        #
        # The following keys are currently available:
        #   * type
        #   * max
        #   * present
        #
        # Following:
        #   * min
        #
        # Usage:
        #   variable = "This is a simple test"
        #   validator = GollumRails::Adapters::ActiveModel::Validation.new 
        #   validator.validate!  do |a|
        #     a.validate(variable, "type=String,max=100,present=true")
        #   end 
        #   validator.valid?
        #   # => true
        #
        # Params:
        #   block - Block to use
        #
        # Returns:
        def validate(&block)
          bla = block.call(self)
        end
        
        # Aliasing test method
        alias_method :validate!, :test


        # Tests given variable for conditions
        #
        # Params:
        #   variable - variable to validate
        #   statement - validation statement, seperated by coma
        #
        #
        def test(variable,statement)
          if statement.include? ','
            validation = Hash[ statement.split(',').map{|k| k.split(/\=/,2) if k.include? '='} ]
          elsif statement.include? '='
            validation = Hash[ statement.split(/\=/,2) ]
          else
            raise GollumRails::Adapters::ActiveModel::Error, 'Syntax error! '
          end
          self.instance_variable_set("@variable", variable)
          validation.each_with_index do |k|
            ran = (0...3).map{(65+rand(26)).chr}.join.downcase

            if k.first.to_s.match /^type$/i
              code = <<-END
                self.singleton_class.class_exec do attr_accessor :type end
                self.instance_variable_set("@type", "#{k[1]}")
                validates_with ValidateType, :fields => [:variable]
              END
            elsif k.first.to_s.match /present/i
              code = <<-END
                self.singleton_class.class_exec do attr_accessor :presence end
                self.instance_variable_set("@presence", "#{k[1]}")
                validates_with ValidatePresence, :fields => [:variable]
              END
            end
            self.instance_eval(code) if code
          end
          valid?
        end
      end


      # Validation helper for type:
      #
      # <b>Type</b>
      class ValidateType < ::ActiveModel::Validator

        # validate template generated by activemodel
        def validate(record)
          puts record.type
          if record.type.match(/^\w+$/i)
            name = eval record.type
            return true if record.variable.kind_of? name
            record.errors[:type] << "not a kind of given class #{record.type}"
          else
            record.errors[:type] << "invalid input detected"
          end
          # return recorddd.variable.type_of?
        end
      end
      
      # Validation helper for type:
      #
      # <b>length</b>
      class ValidateLength < ::ActiveModel::Validator

        # validate template generated by activemodel
        def validate(record)
        end
      end

      # Validation helper for type:
      #
      # <b>presence</b>
      class ValidatePresence < ::ActiveModel::Validator

        # Checks if the given string is either nil, empty or 0
        #
        # Returns true or false
        def nil_zero?(value)
         value.nil? || value == 0 || value.empty?
        end

        # Converts String into boolean
        #
        # Necessary for the conversion checks
        #
        # Returns true or false
        def to_boolean(value)
          value == "true"
        end

        # Validates the presence of the given object
        #
        # sets: @errors
        #
        # Returns void
        def validate(record)
          #return nil_zero? record.variable if record.presence.kind_of?(Boolean)
          #return nil_zero? record.variable if to_boolean record.presence
          #record.errors[:presence] << "content is empty #{record.variable}"
        end
      end

    end
  end
end
