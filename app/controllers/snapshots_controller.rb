class SnapshotsController < ApplicationController

  # GET /snapshots/1
  # GET /snapshots/1.json
  def show
    @snapshot = @wall.snapshots.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @snapshot }
    end
  end

  # POST /snapshots
  # POST /snapshots.json
  def create
    @snapshot = @wall.new_snapshot(params[:snapshot][:file])
    @snapshot.in_analysis = 0
    respond_to do |format|
      if @snapshot.save
        @snapshot.delay.analysis!
        format.html { redirect_to [@wall, @snapshot] }
        format.json { render json: @snapshot, status: :created, location: [@wall, @snapshot] }
      else
        format.html { redirect_to [@wall, @snapshot], notice: 'Upload snapshot failed.' }
        format.json { render json: @snapshot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snapshots/1
  # DELETE /snapshots/1.json
  def destroy
    @snapshot = @wall.snapshots.find(params[:id])
    @snapshot.destroy

    respond_to do |format|
      format.html { redirect_to @wall }
      format.json { head :no_content }
    end
  end

  def diff
    @snapshot1 = @wall.snapshots.find_by_id(params[:snapshot_id])
    @snapshot2 = @wall.snapshots.find_by_id(params[:diff_with_snapshot_id])
    @grid = @snapshot1.grid
    @changes = @grid.diff(@snapshot2.grid)
  end
end
