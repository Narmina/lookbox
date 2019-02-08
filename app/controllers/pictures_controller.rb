class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]
  before_action :set_look_pictures_search, only: :index, if: proc{ params[:look_id].present? }
  protect_from_forgery except: :index
  #respond_to :html, :js

  include SearchFilter

  # GET /pictures
  def index
    @search, @pictures = filtered_pictures(current_user.pictures, params)
    respond_to do |format|
      format.html 
      format.js do
        @available_pictures = @pictures
        search_view = if params[:look_id] then 'looks/available_pictures' elsif params[:category_id] then 'categories/available_pictures' else {js: 'No results was found'}  end
        render search_view
      end
    end
  end

  # GET /pictures/1
  def show
    #if stale?(last_modified: @picture.updated_at.utc, etag: @picture.cache_key)
      respond_to do |format|
        format.html
        format.js
      end
    #end
  end

  # GET /pictures/new
  def new
    @picture = current_user.pictures.new.decorate
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  def create
    @picture = current_user.pictures.new(picture_params.except(:image)).decorate
    respond_to do |format|
      if @picture.save
        @picture.image = picture_params[:image] if picture_params[:image].present?
        @picture.save if @picture.changed?
        format.html { redirect_to pictures_path, notice: success_action_notice('created') }
        format.js { render :create }
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /pictures/1
  def update
    respond_to do |format|
      if @picture.update(picture_params) #update_attributes
        format.html { redirect_to pictures_path, notice: success_action_notice('updated') }
        format.js { render :update, locals: {notice: success_action_notice('updated')} }
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /pictures/1
  def destroy
    @picture.destroy
    respond_to do |format|
      format.html { redirect_to pictures_url, notice: success_action_notice('destroyed') }
    end
  end

  def refresh
    respond_to do |format|
      format.html do
        session.delete(:pictures_filter)
        redirect_to pictures_path
      end
      format.js do
        session.delete :look_pictures_search
        redirect_to pictures_path(look_id: params[:look_id])
      end
    end
  end

  def copy
    @picture = current_user.pictures.find(params[:id]).duplicate
    respond_to do |format|
      format.html { render :index, notice: success_action_notice('copied')}
      format.js { render :copy, locals: {notice: success_action_notice('copied')} }
    end
  end

  private
    def success_action_notice(action)
      "Picture was successfully #{action}."
    end

    def set_picture
      @picture = current_user.pictures.find(params[:id]).decorate
    end

    def set_look_pictures_search
      session[:look_pictures_search] = { page:  params[:page], q: params[:q]} if params[:page]
      params.deep_merge!(session[:look_pictures_search]) if params[:restore_page].present? && session[:look_pictures_search]
    end

    def paginate_pictures(pictures, per_page)
      Kaminari.paginate_array(PictureDecorator.wrap(pictures)).page(params[:page]).per(per_page)
    end

    def picture_params
      params.require(:picture).transform_keys{|k| k.sub('image_crop', 'crop')}.permit(:crop_x, :crop_y, :crop_w, :crop_h, :title, :description, :rotation, :user_id, :image, :direct_image_url, :link, category_ids: [])
    end

end
