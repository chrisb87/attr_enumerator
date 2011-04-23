require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AttrEnumerator" do
  subject { TestModel }

  def instance
    @instance ||= subject.new
  end

  after(:each) do
    begin
      Object.send(:remove_const, :TestModel)
    rescue NameError
    end
  end

  context "without ActiveRecord" do
    before(:each) do
      class TestModel
        include ActiveModel::Validations
        include AttrEnumerator
        attr_accessor :choice
      end
    end

    context "validation" do
      it "should pass when the value is one of the choices" do
        subject.attr_enumerator :choice, :in => ['red', 'blue']
        instance.choice = 'blue'
        instance.should be_valid
      end

      it "should fail when the value is not one of the choices" do
        subject.attr_enumerator :choice, :in => ['red', 'blue']
        instance.choice = 'green'
        instance.should_not be_valid
      end

      it "should have a default message" do
        subject.attr_enumerator :choice, :in => ['red', 'blue']
        instance.valid?
        instance.errors.should == {:choice => ['is invalid']}
      end

      it "should allow for a custom message" do
        subject.attr_enumerator :choice, :in => ['red', 'blue'], :message => '%{value} is not a valid color'
        instance.choice = 'green'
        instance.valid?
        instance.errors.should == {:choice => ['green is not a valid color']}
      end

      it "should handle allow_blank" do
        subject.attr_enumerator :choice, :in => ['red', 'blue'], :allow_blank => true

        instance.choice = nil
        instance.should be_valid

        instance.choice = ''
        instance.should be_valid
      end

      it "should handle allow_nil" do
        subject.attr_enumerator :choice, :in => ['red', 'blue'], :allow_nil => true

        instance.choice = nil
        instance.should be_valid

        instance.choice = ''
        instance.should_not be_valid
      end

      it "should handle symbol enumerations distinctively from strings" do
        subject.attr_enumerator :choice, :in => [:red, :blue]

        instance.choice = :red
        instance.should be_valid
        instance.should be_choice_red

        instance.choice = 'red'
        instance.should_not be_valid
        instance.should_not be_choice_red
      end
    end

    context "class constant" do
      it "should create a constant by default" do
        subject.attr_enumerator :choice, :in => ['red', 'blue']
        subject::CHOICES.should == ['red', 'blue']
      end

      it "should freeze the constant to prevent editing" do
        subject.attr_enumerator :choice, :in => ['red', 'blue']
        subject::CHOICES.should be_frozen
      end

      it "should allow for a custom constant name using a symbol" do
        subject.attr_enumerator :choice, :in => ['red', 'blue'], :constant => :POSSIBLE_COLORS
        subject::POSSIBLE_COLORS.should == ['red', 'blue']
      end

      it "should allow for a custom constant name using a string" do
        subject.attr_enumerator :choice, :in => ['red', 'blue'], :constant => 'POSSIBLE_COLORS'
        subject::POSSIBLE_COLORS.should == ['red', 'blue']
      end
    end

    context "methods" do
      it "should create methods for each enumeration by default" do
        subject.attr_enumerator :choice, :in => ['red', 'blue']
        instance.choice = 'red'

        instance.should respond_to :choice_red?
        instance.should be_choice_red

        instance.should respond_to :choice_blue?
        instance.should_not be_choice_blue
      end

      it "should create methods with friendly names" do
        enumerations = {
          :has_space? => 'has space',
          :has_dash? => 'has-dash',
          :other_characters? => 'other%*characters',
          :uppercase? => 'UPPERCASE',
          :camel_case? => 'CamelCase',
          :ends_with_dot? => 'ends.with.dot.'
        }

        subject.attr_enumerator :choice, :in => enumerations.values, :prefix => false

        enumerations.keys.each do |method_name|
          instance.should respond_to method_name
        end
      end

      it "should allow for a custom prefix" do
        subject.attr_enumerator :choice, :in => ['red', 'blue'], :prefix => 'colored'
        instance.choice = 'red'

        instance.should respond_to :colored_red?
        instance.should be_colored_red

        instance.should respond_to :colored_blue?
        instance.should_not be_colored_blue
      end
      
      it "should allow for no prefix" do
        subject.attr_enumerator :choice, :in => ['red', 'blue'], :prefix => false
        instance.choice = 'red'

        instance.should respond_to :red?
        instance.should be_red

        instance.should respond_to :blue?
        instance.should_not be_blue
      end
    end
  end

  context "with ActiveRecord" do
    before(:each) do
      class TestModel < ActiveRecordModel
        attr_accessor :choice
      end
    end

    it "should automatically be included in ActiveRecord::Base" do
      ActiveRecord::Base.should respond_to :attr_enumerator
    end

    describe "scopes" do
      it "should create a scope for each enumeration" do
        subject.attr_enumerator :choice, :in => ['red', 'blue']
        subject.choice_red.should be_a ActiveRecord::Relation
      end
      
      it "should create a scope for each enumeration with custom prefix " do
        subject.attr_enumerator :choice, :in => ['red', 'blue'], :prefix => 'colored'
        subject.colored_red.should be_a ActiveRecord::Relation
      end
      
      it "should create a scope for each enumeration without prefix " do
        subject.attr_enumerator :choice, :in => ['red', 'blue'], :prefix => false
        subject.red.should be_a ActiveRecord::Relation
      end
    end
  end
end
