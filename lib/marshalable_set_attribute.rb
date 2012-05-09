module MarshalableSetAttribute       
  attr_accessor :marshalable_attribute
    
  class StatusSet
    attr_accessor :status_set
    delegate :add, :to => :@status_set
    delegate :delete, :to => :@status_set          

    def initialize(provision_status, context)
      @status_set = Marshal.load(provision_status) rescue Set.new
      @context = context
    end
    
    def save!
      @context.update_set! Marshal.dump(@status_set)
    end
  end  
  
  module ClassMethods
    def marshalable_set_attribute(attribute)
      MarshalableSetAttribute.instance_variable_set '@marshalable_attribute', attribute
      self.send :include, InstanceMethods
    end
  end
  
  module InstanceMethods       
    def self.included(receiver)      
      marshalable_attribute = MarshalableSetAttribute.instance_variable_get '@marshalable_attribute'
      define_method "#{marshalable_attribute}_set" do
        @set ||= StatusSet.new(self.send(marshalable_attribute), self)      
      end       
    end

    def update_set!(marshaled_status)
      marshalable_attribute = MarshalableSetAttribute.instance_variable_get '@marshalable_attribute'            
      self.update_attributes marshalable_attribute => marshaled_status
    end    
  end
  
  def self.included(receiver)
    receiver.extend ClassMethods
  end  
end