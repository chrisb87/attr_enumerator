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

  describe "enum constant" do
    it "should create a constant with possible values" do
      TestModel.attr_enumerator :color, ['red', 'blue']
      TestModel::COLORS.should == ['red', 'blue']
    end

    it "should allow for a custom constant name" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :constant => :POSSIBLE_COLORS
      TestModel::POSSIBLE_COLORS.should == ['red', 'blue']
    end

    it "should allow for not generating the constant" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :constant => false
      TestModel.constants.should_not include('COLORS')
    end

    it "should define the standard constant when using option :constant => true" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :constant => true
      TestModel::COLORS.should == ['red', 'blue']
    end
  end

  describe "convinience methods" do
    it "should create convinience methods for each enum type" do
      TestModel.attr_enumerator :color, ['red', 'blue']
      instance.color = 'red'

      instance.should respond_to :red?
      instance.red?.should be_true

      instance.should respond_to :blue?
      instance.blue?.should be_false
    end

    it "should allow for prefixing the convinience methods" do
      TestModel.attr_enumerator :color, ['red', 'blue'], :prefix => 'colored_'
      instance.color = 'red'

      instance.should respond_to :colored_red?
      instance.colored_red?.should be_true

      instance.should respond_to :colored_blue?
      instance.colored_blue?.should be_false
    end

    it "should handle strangely formated choices" do
      TestModel.attr_enumerator :choices, \
      ['choice one', 'choice-two', 'CHOICE THREE', 'ChoiceFour', 'choice%five', 'choice☺six', 'choice_seven.']

      instance.should respond_to :choice_one?
      instance.should respond_to :choice_two?
      instance.should respond_to :choice_three?
      instance.should respond_to :choice_four?
      instance.should respond_to :choice_five?
      instance.should respond_to :choice_six?
      instance.should respond_to :choice_seven?
    end
  end

  describe "validation" do
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
  end

  describe "ActiveRecord" do
    it "should respond to attr_enumerator" do
      ActiveRecord::Base.should respond_to :attr_enumerator
    end
  end
end
