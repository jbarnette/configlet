require "minitest/autorun"
require "configlet"

class TestConfiglet < MiniTest::Unit::TestCase
  class Stub
    include Configlet
  end

  def setup
    @cfg = Stub.new
    @env = ENV.to_hash
  end

  def teardown
    ENV.replace @env
  end

  def test_config
    ENV["PREFIX_FOO"] = "bar"

    @cfg.config :prefix do
      default :bar => "baz"
    end

    assert_equal "bar", @cfg[:foo]
    assert_equal "baz", @cfg[:bar]
  end

  def test_default
    assert_nil @cfg["foo"]

    @cfg.default :foo => "bar"
    assert_equal "bar", @cfg["foo"]
  end

  def test_get
    ENV["FOO"] = "bar"
    assert_equal "bar", @cfg[:foo]

    @cfg.prefix = "boom"
    ENV["BOOM_FOO"] = "bar"
    assert_equal "bar", @cfg[:foo]
  end

  def test_munge
    ENV["STUPID"] = "true"
    @cfg.munge(:stupid) { |v| "true" == v }
    assert_equal true, @cfg[:stupid]
  end

  def test_set
    assert_nil ENV["FOO"]
    @cfg[:foo] = "bar"
    assert_equal "bar", ENV["FOO"]

    @cfg.prefix = "pow"
    @cfg[:thud] = "zap"
    assert_equal "zap", ENV["POW_THUD"]
  end
end
