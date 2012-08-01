class CardsController < ApplicationController
  before_filter :load_wall
  before_filter :load_snapshot

  def update
    @card = @snapshot.cards.find_by_id(params[:id])
    respond_to do |format|
      if @card.update_attributes(params[:card])
        format.json { head :no_content }
      else
        format.json { render json: @snapshot.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def load_wall
    @wall = Wall.find(params[:wall_id])
  end
  def load_snapshot
    @snapshot = @wall.snapshots.find(params[:snapshot_id])
  end
end
