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
        subject.attr_enumerator :choice, ['red', 'blue']
        instance.choice = 'blue'
        instance.should be_valid
      end

      it "should fail when the value is not one of the choices" do
        subject.attr_enumerator :choice, ['red', 'blue']
        instance.choice = 'green'
        instance.should_not be_valid
      end

      it "should have a default message" do
        subject.attr_enumerator :choice, ['red', 'blue']
        instance.valid?
        instance.errors.should == {:choice => ['is invalid']}
      end

      it "should allow for a custom message" do
        subject.attr_enumerator :choice, ['red', 'blue'], :message => '%{value} is not a valid color'
        instance.choice = 'green'
        instance.valid?
        instance.errors.should == {:choice => ['green is not a valid color']}
      end

      it "should handle allow_blank" do
        subject.attr_enumerator :choice, ['red', 'blue'], :allow_blank => true

        instance.choice = nil
        instance.should be_valid

        instance.choice = ''
        instance.should be_valid
      end

      it "should handle allow_nil" do
        subject.attr_enumerator :choice, ['red', 'blue'], :allow_nil => true

        instance.choice = nil
        instance.should be_valid

        instance.choice = ''
        instance.should_not be_valid
      end

      it "should handle symbols as enumerations" do
        subject.attr_enumerator :choice, [:red, :blue]

        instance.choice = :red
        instance.should be_valid
        instance.should be_choice_red

        instance.choice = 'red'
        instance.should_not be_valid
      end
    end

    context "class constant" do
      it "should create a constant by default" do
        subject.attr_enumerator :choice, ['red', 'blue']
        subject::CHOICES.should == ['red', 'blue']
      end

      it "should freeze the constant to prevent editing" do
        subject.attr_enumerator :choice, ['red', 'blue']
        subject::CHOICES.should be_frozen
      end

      it "should allow for explicitly creating the default constant" do
        subject.attr_enumerator :choice, ['red', 'blue'], :create_constant => true
        subject::CHOICES.should == ['red', 'blue']
      end

      it "should allow for a custom constant name using a symbol" do
        subject.attr_enumerator :choice, ['red', 'blue'], :create_constant => :POSSIBLE_COLORS
        subject::POSSIBLE_COLORS.should == ['red', 'blue']
      end

      it "should allow for a custom constant name using a string" do
        subject.attr_enumerator :choice, ['red', 'blue'], :create_constant => 'POSSIBLE_COLORS'
        subject::POSSIBLE_COLORS.should == ['red', 'blue']
      end

      it "should allow for not creating a constant" do
        subject.attr_enumerator :choice, ['red', 'blue'], :create_constant => false
        subject.constants.should_not include('COLORS')
      end
    end

    context "methods" do
      it "should create methods for each enumeration by default" do
        subject.attr_enumerator :choice, ['red', 'blue']
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

        subject.attr_enumerator :choice, enumerations.values, :prefix => false, :suffix => false

        enumerations.keys.each do |method_name|
          instance.should respond_to method_name
        end
      end

      it "should allow for explicitly creating the default methods" do
        subject.attr_enumerator :choice, ['red', 'blue'], :create_methods => true
        instance.choice = 'red'

        instance.should respond_to :choice_red?
        instance.should be_choice_red
      end

      it "should allow for not creating methods" do
        subject.attr_enumerator :choice, ['red', 'blue'], :create_methods => false
        instance.should_not respond_to :choice_red?
      end

      it "should allow for a custom prefix" do
        subject.attr_enumerator :choice, ['red', 'blue'], :prefix => 'colored'
        instance.choice = 'red'

        instance.should respond_to :colored_red?
        instance.should be_colored_red

        instance.should respond_to :colored_blue?
        instance.should_not be_colored_blue
      end

      it "should allow for explicitly using the default prefix" do
        subject.attr_enumerator :choice, ['red', 'blue'], :prefix => true
        instance.should respond_to :choice_red?
      end

      it "should allow for no prefix" do
        subject.attr_enumerator :choice, ['red', 'blue'], :prefix => false
        instance.should respond_to :red?
      end

      it "should not have a suffix by default" do
        subject.attr_enumerator :choice, ['red', 'blue']
        instance.should respond_to :choice_red?
      end

      it "should allow for explicitly having no suffix" do
        subject.attr_enumerator :choice, ['red', 'blue'], :suffix => false
        instance.should respond_to :choice_red?
      end

      it "should use the field as a suffix when :suffix is true" do
        subject.attr_enumerator :choice, ['red', 'blue'], :suffix => true
        instance.should respond_to :choice_red_choice?
      end

      it "should allow for a custom suffix" do
        subject.attr_enumerator :choice, ['red', 'blue'], :suffix => 'custom'
        instance.should respond_to :choice_red_custom?
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
      it "should create a scope for each enumeration by default" do
        subject.attr_enumerator :choice, ['red', 'blue']
        subject.choice_red.should be_a ActiveRecord::Relation
      end

      it "should allow for explicitly creating scopes" do
        subject.attr_enumerator :choice, ['red', 'blue'], :create_scopes => true
        subject.choice_red.should be_a ActiveRecord::Relation
      end

      it "should allow for not creating scopes" do
        subject.attr_enumerator :choice, ['red', 'blue'], :create_scopes => false
        subject.should_not respond_to :choice_red
      end
    end
  end
end
