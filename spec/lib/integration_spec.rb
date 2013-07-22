require 'spec_helper'

# Example
class MyCommand
  include Wisper::Publisher

  def execute(be_successful)
    if be_successful
      broadcast('success', 'hello')
    else
      broadcast('failure', 'world')
    end
  end
end

describe Wisper do

  it 'subscribes object to all published events' do
    listener = double('listener')
    listener.should_receive(:success).with('hello')

    command = MyCommand.new

    command.add_listener(listener)

    command.execute(true)
  end

  it 'subscribes block to all published events' do
    insider = double('Insider')
    insider.should_receive(:render).with('hello')

    command = MyCommand.new

    command.add_block_listener do |message|
      insider.render(message)
    end

    command.execute(true)
  end

  it 'maps events to different methods' do
    listener_1 = double('listener')
    listener_2 = double('listener')
    listener_1.should_receive(:happy_days).with('hello')
    listener_2.should_receive(:sad_days).with('world')

    command = MyCommand.new

    command.add_listener(listener_1, :on => :success, :with => :happy_days)
    command.add_listener(listener_2, :on => :failure, :with => :sad_days)

    command.execute(true)
    command.execute(false)
  end

  it 'subscribes block can be chained' do
    insider = double('Insider')

    insider.should_receive(:render).with('success')
    insider.should_receive(:render).with('failure')

    command = MyCommand.new

    command.on(:success) { |message| insider.render('success') }
           .on(:failure) { |message| insider.render('failure') }

    command.execute(true)
    command.execute(false)
  end

  it 'chains block subscribers with named subscribers' do
    insider = double('Insider')
    listener = double('listener')

    listener.should_receive(:render).with('success')
    insider.should_receive(:render).with('success')

    command = MyCommand.new
    command.on(:foo) { |message| insider.render('success') }
    command.subscribe(listener)

    command.execute(true)
  end
end
