require 'spec_helper'

describe Backend do
  before(:each) {@connection = Redis.new}
  after(:each) {@connection.flushdb}

  describe ".summary" do
    it "call the optimized routine if the proper keys exist" do
      @connection.zincrby("offenders", 10, "1.1.1.1")
      @connection.sadd("detected", "950001")
      Backend.should_receive(:optimized) { [{},{}] }
      Backend.summary(@connection)
    end

    it "calls the standard routine if they don't" do
      @connection.del("offenders")
      @connection.sadd("detected", "950001")
      Backend.should_receive(:standard) { [{},{}] }
      Backend.summary(@connection)
    end
  end
end
