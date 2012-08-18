require 'test_helper'

class SnapshotsControllerTest < ActionController::TestCase
  setup do
    @snapshot = snapshots(:one)
    @snapshot.wall.ensure_root_directory
  end

  test "should show snapshot" do
    get :show, wall_id: @snapshot.wall_id, id: @snapshot
    assert_response :success
  end
end
