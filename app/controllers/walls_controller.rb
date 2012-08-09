class WallsController < ApplicationController
  skip_before_filter :authenticate, :only => [:index, :new, :create]

  # GET /walls
  # GET /walls.json
  def index
    @walls = Wall.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @walls }
    end
  end

  # GET /walls/1
  # GET /walls/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @wall }
    end
  end

  # GET /walls/new
  # GET /walls/new.json
  def new
    @wall = Wall.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @wall }
    end
  end

  # GET /walls/1/edit
  def edit
  end

  # POST /walls
  # POST /walls.json
  def create
    @wall = Wall.new(params[:wall])

    respond_to do |format|
      if @wall.save
        mark_authenticated(@wall, true)
        format.html { redirect_to @wall, notice: 'Wall was successfully created.' }
        format.json { render json: @wall, status: :created, location: @wall }
      else
        format.html { render action: "new" }
        format.json { render json: @wall.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /walls/1
  # PUT /walls/1.json
  def update
    respond_to do |format|
      if @wall.update_attributes(params[:wall])
        format.html { redirect_to @wall, notice: 'Wall was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @wall.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /walls/1
  # DELETE /walls/1.json
  def destroy
    @wall.destroy

    respond_to do |format|
      format.html { redirect_to walls_url }
      format.json { head :no_content }
    end
  end

  def export
    @wall = Wall.find(params[:wall_id])
    @file = @wall.export_file(Dir.tmpdir)
    @wall.delay.export(@file)
  end

  def download
    file = params[:file]
    respond_to do |format|
      format.ewall { send_file file, :filename => File.basename(file), :type => 'application/ewall' }
      format.json { render json: File.exist?(file) }
    end
  end

  def import
    @file = params[:file].tempfile.path
    @importer = ExportImport.new
    @importer.ensure_target_dir
    @importer.delay.import(@file)
  end

  def import_progress
    @importing_dir = params[:importing_dir]
    respond_to do |format|
      format.json { render json: !File.exist?(@importing_dir) }
    end
  end

  protected
  def load_wall
    @wall = Wall.find(params[:id]) if params[:id]
  end
end
