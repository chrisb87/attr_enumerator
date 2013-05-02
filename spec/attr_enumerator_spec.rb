require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AttrEnumerator" do
  let(:car)     { Car.new }

  context "without ActiveRecord" do
    before(:each) do
      class Car
        include ActiveModel::Validations
        include AttrEnumerator
        attr_accessor :color
      end
    end

    after(:each)  { Object.send(:remove_const, :Car) }

    context "validation" do
      it "should pass when the value is one of the choices" do
        Car.attr_enumerator :color, ['red', 'blue']
        car.color = 'blue'
        car.should be_valid
      end

      it "should fail when the value is not one of the choices" do
        Car.attr_enumerator :color, ['red', 'blue']
        car.color = 'green'
        car.should_not be_valid
      end

      it "should have a default message" do
        Car.attr_enumerator :color, ['red', 'blue']
        car.valid?
        car.errors[:color].should == ['is invalid']
      end

      it "should allow for a custom message" do
        Car.attr_enumerator :color, ['red', 'blue'], :message => '%{value} is not a valid color'
        car.color = 'green'
        car.valid?
        car.errors[:color].should == ['green is not a valid color']
      end

      it "should handle allow_blank" do
        Car.attr_enumerator :color, ['red', 'blue'], :allow_blank => true

        car.color = nil
        car.should be_valid

        car.color = ''
        car.should be_valid
      end

      it "should handle allow_nil" do
        Car.attr_enumerator :color, ['red', 'blue'], :allow_nil => true

        car.color = nil
        car.should be_valid

        car.color = ''
        car.should_not be_valid
      end

      it "should handle symbol choices distinctively from strings" do
        Car.attr_enumerator :color, [:red, :blue]

        car.color = :red
        car.should be_valid
        car.should be_red

        car.color = 'red'
        car.should_not be_valid
        car.should_not be_red
      end
    end

    context "class constant" do
      it "should create a constant" do
        Car.attr_enumerator :color, ['red', 'blue']
        Car::COLORS.should == ['red', 'blue']
      end

      it "should freeze the constant" do
        Car.attr_enumerator :color, ['red', 'blue']
        Car::COLORS.should be_frozen
      end

      it "should allow for a custom constant name using a symbol" do
        Car.attr_enumerator :color, ['red', 'blue'], :constant => :POSSIBLE_COLORS
        Car::POSSIBLE_COLORS.should == ['red', 'blue']
      end

      it "should allow for a custom constant name using a string" do
        Car.attr_enumerator :color, ['red', 'blue'], :constant => 'POSSIBLE_COLORS'
        Car::POSSIBLE_COLORS.should == ['red', 'blue']
      end
    end

    context "methods" do
      it "should create methods for each choice" do
        Car.attr_enumerator :color, ['red', 'blue']
        car.color = 'red'

        car.should respond_to :red?
        car.should be_red

        car.should respond_to :blue?
        car.should_not be_blue
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

        Car.attr_enumerator :color, enumerations.values

        enumerations.keys.each do |method_name|
          car.should respond_to method_name
        end
      end

      it "should allow for a custom prefix" do
        Car.attr_enumerator :color, ['red', 'blue'], :prefix => 'painted'
        car.color = 'red'

        car.should respond_to :painted_red?
        car.should be_painted_red

        car.should respond_to :painted_blue?
        car.should_not be_painted_blue
      end
    end
  end

  context "with ActiveRecord" do
    before(:each) do
      class Car < ActiveRecord::Base
        establish_connection(:adapter => 'sqlite3', :database => ':memory:')
        attr_accessor :color
      end
    end

    after(:each)  { Object.send(:remove_const, :Car) }

    it "should automatically be included in ActiveRecord::Base" do
      ActiveRecord::Base.should respond_to :attr_enumerator
    end

    describe "scopes" do
      it "should create a scope for each enumeration" do
        Car.attr_enumerator :color, ['red', 'blue']
        Car.red.should be_a ActiveRecord::Relation
      end

      it "should allow for scopes with a custom prefix" do
        Car.attr_enumerator :color, ['red', 'blue'], :prefix => 'painted'
        Car.painted_red.should be_a ActiveRecord::Relation
      end
    end
  end
end
