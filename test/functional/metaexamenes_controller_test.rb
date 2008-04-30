require File.dirname(__FILE__) + '/../test_helper'
require 'metaexamenes_controller'

# Re-raise errors caught by the controller.
class MetaexamenesController; def rescue_action(e) raise e end; end

class MetaexamenesControllerTest < Test::Unit::TestCase
  fixtures :metaexamenes

  def setup
    @controller = MetaexamenesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = metaexamenes(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:metaexamenes)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:metaexamen)
    assert assigns(:metaexamen).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:metaexamen)
  end

  def test_create
    num_metaexamenes = Metaexamen.count

    post :create, :metaexamen => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_metaexamenes + 1, Metaexamen.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:metaexamen)
    assert assigns(:metaexamen).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Metaexamen.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Metaexamen.find(@first_id)
    }
  end
end
