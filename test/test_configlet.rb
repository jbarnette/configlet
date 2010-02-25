require "minitest/autorun"
require "configlet"

class TestConfiglet < MiniTest::Unit::TestCase
  def setup
    @env = ENV.to_hash
    Configlet.reset
  end

  def teardown
    ENV.replace @env
  end

  def test_default
    assert_nil Configlet["foo"]

    Configlet.default :foo => "bar"
    assert_equal "bar", Configlet["foo"]
  end

  def test_for
    ENV["PREFIX_FOO"] = "bar"

    Configlet.for :prefix do
      default :bar => "baz"
    end

    assert_equal "bar", Configlet[:foo]
    assert_equal "baz", Configlet[:bar]
  end

  def test_get
    ENV["FOO"] = "bar"
    assert_equal "bar", Configlet[:foo]

    Configlet.prefix = "boom"
    ENV["BOOM_FOO"] = "bar"
    assert_equal "bar", Configlet[:foo]
  end

  def test_munge
    ENV["STUPID"] = "true"
    Configlet.munge(:stupid) { |v| "true" == v }
    assert_equal true, Configlet[:stupid]
  end

  def test_set
    assert_nil ENV["FOO"]
    Configlet[:foo] = "bar"
    assert_equal "bar", ENV["FOO"]

    Configlet.prefix = "pow"
    Configlet[:thud] = "zap"
    assert_equal "zap", ENV["POW_THUD"]
  end
end
