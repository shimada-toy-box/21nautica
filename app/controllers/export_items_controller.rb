class ExportItemsController < ApplicationController
  def create
    export = Export.find(params[:export_id])
    export.export_items.create(export_items_params)
    render nothing: :true
  end

  def update
    export = ExportItem.find(export_items_params[:id])
    if export.update_attributes(export_items_params)
      render text: export_items_params[:container] || export_items_params[:date_of_placement] ||export_items_params[:location]
    else
      render text: export.errors.full_messages
    end
  end

  private
  def export_items_params
    params.permit(:container, :location, :date_of_placement, :export_id, :id)
  end
end