require "test_helper"

class CombatTest < ActiveSupport::TestCase
  def combat
    @combat ||= Combat.new
  end

  def test_valid
    assert combat.valid?
  end
end
