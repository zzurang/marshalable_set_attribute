require 'spec_helper'
require 'marshalable_set_attribute'

describe MarshalableSetAttribute do
  class Foo
    include MarshalableSetAttribute    
    attr_accessor :bar    
    marshalable_set_attribute :bar 
  end
  
  before(:each) do
    @foo = Foo.new
    @set = @foo.bar_set
  end
  
  describe "instance_methods" do  
    it "should respond to #bar_set" do
      @foo.should respond_to(:bar_set)
    end
    
    describe "bar_set" do      
      describe "#add" do
        it "should add an element" do
          @set.add(1).include?(1).should be_true          
        end
      end
      
      describe "#delete" do
        it "should delete an element" do
          @set.add(1)
          @set.delete(1).include?(1).should be_false
        end
      end      
      
      describe "#save!" do
        it "should update_attributes for attribute :bar with marshaled set" do
          @foo.should_receive(:update_attributes).with(:bar => anything).once
          @set.save!          
        end
      end      
    end
    
    describe "marshal/unmarshal" do
      before(:each) do
        @set.add(1)
        @comparing_set = Set.new
        @comparing_set.add(1)        
      end
      
      describe "marshal" do
        it "should marshal the set before save" do      
          @foo.should_receive(:update_attributes).with(:bar => Marshal.dump(@comparing_set)).once
          @set.save!
        end
      end  
      
      describe "unmarshal" do
        it "should unmarshal the set before read" do      
          Marshal.should_receive(:load).with(nil).once
          Foo.new.bar_set
        end
      end    
    end
  end  
end