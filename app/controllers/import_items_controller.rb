class ImportItemsController < ApplicationController

  def index
    param = params[:destination_item] if params[:destination_item].present?
    imports = Import.includes(:import_item).where(status: "ready_to_load").where(to: param || 'Kampala').select("id")
    @import_items = ImportItem.where(import_id: imports).where.not(status: "delivered")
    @transporters = Vendor.transporters.pluck(:name).inject({}) {|h, x| h[x] = x; h}
  end

  def edit
    @import_item = ImportItem.find params[:id]
  end

  def update
    import_item = ImportItem.find(import_item_update_params[:id])
    attribute = import_item_update_params[:columnName].downcase.gsub(' ', '_').to_sym
    attribute = import_item_update_params[:columnName].downcase.gsub('/', '_').gsub(' ','_').to_sym
    if import_item.update(attribute => import_item_update_params[:value]||import_item_update_params[:g_f_expiry]||import_item_update_params[:close_date])
      render text: import_item_update_params[:value]||import_item_update_params[:g_f_expiry]||import_item_update_params[:close_date]
    else
      render text: import_item.errors.full_messages
    end
  end

  def update_loading_date
    @import_item = ImportItem.find(params[:id])
    @import = @import_item.import
    @import.import_items.update_all(last_loading_date: params[:last_loading_date])
    respond_to do |format|
      format.js
    end
  end

  def updateContext
    @import_item = ImportItem.find(params[:id])
    after_delivery = params[:after_delivery]
    date = Date.today
    @import_item[:after_delivery_status] = after_delivery.humanize
    if(after_delivery == "export_reuse")
      @import_item[:context] = "Customer Name: " + import_item_params[:context]+" , " +date.strftime("%d-%m-%Y")
    elsif(after_delivery == "drop_off")
      @import_item[:context] = "Yard Name: " + import_item_params[:context] +" , " + date.strftime("%d-%m-%Y")
    else
      @import_item[:context] = "Truck Number: " + import_item_params[:context] +" , "+"Transporter: "+import_item_params[:transporter_name]+" , " +date.strftime("%d-%m-%Y")
    end
    @import_item.save
  end

  def updateStatus
    @import_item = ImportItem.find(params[:id])
    @import = @import_item.import
    initial_status = @import_item.status
    @import_item.attributes = import_item_params.except('status')
    if initial_status == "under_loading_process"
      @import_item.allocate_truck
      @import_item.save
    else
      status = import_item_params[:status].downcase.gsub(' ', '_')
      begin
        status != @import_item.status ? @import_item.send("#{status}!".to_sym) : @import_item.save
      rescue
        @errors = @import_item.errors
      end
    end
  end

  def history
    @import_items = ImportItem.where(status: "delivered").order(updated_at: :asc).limit(params[:limit] || 100).offset(params[:offset] || 0)
    @count = ImportItem.where(status: 'delivered').count
    respond_to do |format|
      format.html{}
      format.json { render json: @import_items }
      #format.json{ render json: {data: ImportItem.where(status: "delivered") } }
    end
  end

  def edit_close_date
    @import_item = ImportItem.find(params[:id])
    @import = @import_item.import
  end

  def update_close_date
    @import_item = ImportItem.find(params[:id]) 
    @import_item.update_attributes(close_date: params[:close_date])
  end

  def empty_containers
    @import_items = ImportItem.includes(:import).where(:status => "delivered", :after_delivery_status => nil)
  end

  private

  def import_item_params
    params.permit(:id)
    params.require(:import_item).permit(:truck_number, :status, :remarks, :context, :transporter_name, :transporter, :truck_id, :last_loading_date)
  end

  def import_item_update_params
    params.permit(:id, :columnName, :value,:g_f_expiry,:close_date)
  end
end
