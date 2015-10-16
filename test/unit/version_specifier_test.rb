require 'test_helper'

class VersionSpecifierTest < MiniTest::Unit::TestCase
  def setup
    @yielded = false
  end

  def test_supported_with_min
    VersionSpecifier.supported(min: '3.1') { @yielded = true }
    assert_equal true, @yielded
  end

  def test_supported_with_max
    VersionSpecifier.supported(max: '2.0') { @yielded = true }
    assert_equal false, @yielded
  end

  def test_supported_with_min_and_max
    VersionSpecifier.supported(min: '1.0', max: '5.0') { @yielded = true }
    assert_equal true, @yielded
  end
end
