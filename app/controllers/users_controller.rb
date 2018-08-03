# encoding : utf-8
class UsersController < ApplicationController

  before_filter :ensure_authentication, :only => [:edit, :update, :destroy, :index, :show]
  before_filter :ensure_correct_user, :only => [:edit, :update]

  def index
    @users = User.order(:team_id, :name, :role)
    @teams = Team.order(:name)
    @new_user = User.new
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    @teams = Team.order(:name)
    render layout: false
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @teams = Team.order(:name)
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
  end

  # GET /password
  def password
    if params[:forgot_password_token].present?
      @user = User.where(forgot_password_token: params[:forgot_password_token]).first
    else
      @user = current_user
    end
  end

  def password_update
    if params[:user][:forgot_password_token].present?
      @user = User.where(forgot_password_token: params[:user][:forgot_password_token]).first
    else
      @user = current_user
    end
    @user.password = User.md5(params[:user][:password])
    @user.password_confirmation = User.md5(params[:user][:password_confirmation])

    respond_to do |format|
      if !params[:user][:password].blank? and @user.save
        session[:user_id] = @user.id
        @user.reload
        @user.forgot_password_token = nil
        @user.save
        format.html { redirect_to "/retrospectives", notice: 'Sua senha foi alterada!' }
      else
        format.html { render action: "password", notice: 'Suas senhas não conferem!' }
      end
    end
  end

  # POST /users
  # POST /users.json
  def create
    @teams = Team.order(:name)
    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = "Your profile was succesfully created!"
      redirect_to root_path
    else
      flash[:error] = "Less!! #{@user.errors.full_messages}"
      render action: "new", layout: false
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @teams = Team.order(:name)
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to "/retrospectives", notice: "Your profile was succesfully updated!" }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def authenticate
    user = User.authenticate(params[:email], params[:password])

    if user
      session[:user_id] = user.id
      redirect_to "/retrospectives", notice: "Hello #{user.name}, welcome to Retrospectiba!"
    else
      redirect_to root_url, notice: 'Wrong login or password'
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_url, :alert => "Thanks for using Retrospectiba!"
  end

  def ensure_correct_user
    raise TryingToBeSmartException  if !current_user.admin? && session[:user_id].to_s != params[:id].to_s
  end

  class TryingToBeSmartException < StandardError
  end
end
