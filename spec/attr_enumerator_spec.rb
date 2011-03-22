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

    context "generated constant" do
      it "should generate a constant by default" do
        subject.attr_enumerator :choice, ['red', 'blue']
        subject::CHOICES.should == ['red', 'blue']
      end

      it "should allow for explicitly generating the default constant" do
        subject.attr_enumerator :choice, ['red', 'blue'], :generate_constant => true
        subject::CHOICES.should == ['red', 'blue']
      end

      it "should allow for not generating a constant" do
        subject.attr_enumerator :choice, ['red', 'blue'], :generate_constant => false
        subject.constants.should_not include('COLORS')
      end

      it "should allow for a custom constant name" do
        subject.attr_enumerator :choice, ['red', 'blue'], :generate_constant => :POSSIBLE_COLORS
        subject::POSSIBLE_COLORS.should == ['red', 'blue']
      end

      it "should freeze the constant to prevent editing" do
        subject.attr_enumerator :choice, ['red', 'blue']
        expect { subject::CHOICES << 'green' }.to raise_error(TypeError, "can't modify frozen array")
      end
    end

    context "generated methods" do
      it "should generate methods for each enumeration by default" do
        subject.attr_enumerator :choice, ['red', 'blue']
        instance.choice = 'red'

        instance.should respond_to :choice_red?
        instance.should be_choice_red

        instance.should respond_to :choice_blue?
        instance.should_not be_choice_blue
      end

      it "should allow for explicitly generating the default methods" do
        subject.attr_enumerator :choice, ['red', 'blue'], :generate_methods => true
        instance.choice = 'red'

        instance.should respond_to :choice_red?
        instance.should be_choice_red
      end

      it "should allow for not generating methods" do
        subject.attr_enumerator :choice, ['red', 'blue'], :generate_methods => false
        instance.should_not respond_to :choice_red?
      end

      it "should allow for a custom prefix" do
        subject.attr_enumerator :choice, ['red', 'blue'], :prefix => 'colored_'
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

      it "should allow for a custom suffix" do
        subject.attr_enumerator :choice, ['first', 'second'], :prefix => '', :suffix => '_choice'
        instance.choice = 'first'

        instance.should respond_to :first_choice?
        instance.should be_first_choice
      end

      it "should allow for explicitly using the default suffix" do
        subject.attr_enumerator :choice, ['red', 'blue'], :suffix => true
        instance.should respond_to :choice_red?
      end

      it "should allow for no suffix" do
        subject.attr_enumerator :choice, ['red', 'blue'], :suffix => false
        instance.should respond_to :choice_red?
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

        subject.attr_enumerator :choice, enumerations.values, :prefix => false

        enumerations.keys.each do |method_name|
          instance.should respond_to method_name
        end
      end
    end

    context "validation" do
      it "should have a default message" do
        subject.attr_enumerator :choice, ['red', 'blue']
        instance.should_not be_valid
        instance.errors.should == {:choice => ['is invalid']}
      end

      it "should allow for a custom message" do
        subject.attr_enumerator :choice, ['red', 'blue'], :message => 'custom message'
        instance.should_not be_valid
        instance.errors.should == {:choice => ['custom message']}
      end

      it "should handle allow_blank" do
        subject.attr_enumerator :choice, ['red', 'blue'], :allow_blank => true
        instance.choice = ''
        instance.should be_valid
      end

      it "should handle allow_nil" do
        subject.attr_enumerator :choice, ['red', 'blue'], :allow_nil => true
        instance.choice = nil
        instance.should be_valid
      end

      it "should handle symbols" do
        subject.attr_enumerator :choice, [:red, :blue]

        instance.choice = :red
        instance.should be_valid
        instance.should be_choice_red

        instance.choice = 'red'
        instance.should_not be_valid
      end
    end
  end

  context "with ActiveRecord" do
    before(:each) do
      class TestModel < ActiveRecordModel
        attr_accessor :choice
      end
    end

    it "should automatically be included in ActiveRecord subclasses" do
      subject.should respond_to :attr_enumerator
    end

    describe "generated scopes" do
      it "should generate a scope for each enumeration by default" do
        subject.attr_enumerator :choice, ['red', 'blue']
        subject.should respond_to :choice_red
        subject.choice_red.should be_a ActiveRecord::Relation
      end

      it "should allow for explicitly generating scopes" do
        subject.attr_enumerator :choice, ['red', 'blue'], :generate_scopes => true
        subject.should respond_to :choice_red
        subject.choice_red.should be_a ActiveRecord::Relation
      end

      it "should allow for not generating scopes" do
        subject.attr_enumerator :choice, ['red', 'blue'], :generate_scopes => false
        subject.should_not respond_to :choice_red
      end
    end
  end
end
