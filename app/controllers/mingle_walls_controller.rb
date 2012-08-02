class MingleWallsController < ApplicationController
  def new
    @mingle_wall = @wall.mingle_wall = MingleWall.new
  end

  def show
    unless @wall.mingle_wall
      respond_to do |format|
        format.html { redirect_to :action => 'new' }
      end
    end
  end

  def edit
    @mingle_wall = @wall.mingle_wall
  end

  def update
    @mingle_wall = @wall.mingle_wall
    respond_to do |format|
      if params[:mingle_wall][:password].blank?
        params[:mingle_wall].delete(:password)
      end
      if @mingle_wall.update_attributes(params[:mingle_wall])
        format.html { redirect_to [@wall, @mingle_wall], notice: 'Mingle Wall info was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "show" }
        format.json { render json: @mingle_wall.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @wall.mingle_wall.destroy
    respond_to do |format|
      format.html { redirect_to @wall }
      format.json { head :no_content }
    end
  end

  def pull
    html_body = @wall.mingle_wall.pull
    current_wall_grid = @wall.snapshots.first.grid

    snapshot_columns = current_wall_grid.columns.map{|column| column.body.map{|card| {identifier: card.identifier, image: card.image}}}
    snapshot_heads = current_wall_grid.heads.map{|head| {identifier: head.identifier, image: head.image}}
    render json: { html: html_body, snapshot_columns: snapshot_columns, snapshot_heads: snapshot_heads }
  rescue => e
    render json: { error: e.message }
  end
end
