require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ostruct'

describe "AttrEnumerator" do
  before(:each) do
    class TestModel < OpenStruct
      include ActiveModel::Validations
      include AttrEnumerator
    end
  end

  after(:each) do
    Object.send(:remove_const, :TestModel)
  end

  def instance(fields={})
    @instance ||= TestModel.new(fields)
  end

  context "generated constant" do
    it "should generate a constant by default" do
      TestModel.attr_enumerator :color, ['red', 'blue']
      TestModel::COLORS.should == ['red', 'blue']
    end

    it "should allow for explicitly generating the default constant" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :constant => true
      TestModel::COLORS.should == ['red', 'blue']
    end

    it "should allow for not generating a constant" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :constant => false
      TestModel.constants.should_not include('COLORS')
    end

    it "should allow for a custom constant name" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :constant => :POSSIBLE_COLORS
      TestModel::POSSIBLE_COLORS.should == ['red', 'blue']
    end

    it "should freeze the constant to prevent editing" do
      TestModel.attr_enumerator :color, ['red', 'blue']
      expect { TestModel::COLORS << 'green' }.to raise_error(TypeError, "can't modify frozen array")
    end
  end

  context "generated methods" do
    it "should generate methods for each enumeration" do
      TestModel.attr_enumerator :color, ['red', 'blue']
      instance.color = 'red'

      instance.should respond_to :red?
      instance.should be_red

      instance.should respond_to :blue?
      instance.should_not be_blue
    end

    it "should allow for prefixing the generated methods" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :prefix => 'colored_'
      instance.color = 'red'

      instance.should respond_to :colored_red?
      instance.should be_colored_red

      instance.should respond_to :colored_blue?
      instance.should_not be_colored_blue
    end

    it "should generate methods with friendly names" do
      enumerations = {
        :has_space? => 'has space',
        :has_dash? => 'has-dash',
        :other_characters? => 'other%*characters',
        :uppercase? => 'UPPERCASE',
        :camel_case? => 'CamelCase',
        :ends_with_dot? => 'ends.with.dot.'
      }

      TestModel.attr_enumerator :enumerations, enumerations.values

      enumerations.keys.each do |method_name|
        instance.should respond_to method_name
      end
    end
  end

  context "validation" do
    it "should have a default message" do
      TestModel.attr_enumerator :color, ['red', 'blue']
      instance.should_not be_valid
      instance.errors.should == {:color => ['is invalid']}
    end

    it "should allow for a custom message" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :message => 'custom message'
      instance.should_not be_valid
      instance.errors.should == {:color => ['custom message']}
    end

    it "should handle allow_blank" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :allow_blank => true
      instance.color = ''
      instance.should be_valid
    end

    it "should handle allow_nil" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :allow_nil => true
      instance.color = nil
      instance.should be_valid
    end

    it "should handle symbols" do
      TestModel.attr_enumerator :color, [:red, :blue]

      instance.color = :red
      instance.should be_valid
      instance.should be_red

      instance.color = 'red'
      instance.should_not be_valid
    end
  end

  context "ActiveRecord" do
    it "should automatically work with ActiveRecord" do
      ActiveRecord::Base.should respond_to :attr_enumerator
    end
  end
end
