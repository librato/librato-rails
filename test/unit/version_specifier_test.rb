require 'test_helper'

class VersionSpecifierTest < MiniTest::Unit::TestCase
  def setup
    @version = [Rails::VERSION::MAJOR, Rails::VERSION::MINOR].compact.join('.')
    @yielded = false
  end

  def test_supported_min
    Librato::Rails::VersionSpecifier.supported(min: @version) { @yielded = true }

    assert_equal true, @yielded
  end

  def test_supported_max
    Librato::Rails::VersionSpecifier.supported(max: @version) { @yielded = true }

    assert_equal true, @yielded
  end

  def test_supported_not_yielded
    Librato::Rails::VersionSpecifier.supported(max: '2.0') { @yielded = true }

    assert_equal false, @yielded
  end

  def test_supported_raises
    assert_raises(Librato::Rails::VersionSpecifierError) { Librato::Rails::VersionSpecifier.supported }
    assert_raises(Librato::Rails::VersionSpecifierError) { Librato::Rails::VersionSpecifier.supported(max: '2.0') }
  end
end
