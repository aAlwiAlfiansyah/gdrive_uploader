#!/usr/bin/env ruby

# frozen_string_literal: true

# Class that responsible for running bash script
class SystemRunner
  def run(command)
    p "Running => #{command.chomp}"
    system(command) || raise("Error running #{command}")
  end

  def run_with_output(command)
    # p "Running => #{command.chomp}"
    output = `#{command} 2>&1` || raise("Error running #{command}")
    output.chomp
  end
end

# System runner test double
class TestSystemRunner
  attr_reader :is_running

  def initialize
    @log = []
  end

  def run(command)
    @log.append(command)
    @is_running = true
  end

  def run_with_output(command)
    @log.append(command)
    @is_running = true
  end

  def running?(command)
    @log.include?(command)
  end

  def running_sequence?(*commands)
    @log == commands
  end

  def print_log
    p @log
  end
end
