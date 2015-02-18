class OrderCyclesController < ApplicationController
  before_action :set_order_cycle, only: [:show, :edit, :update, :destroy]

  # GET /order_cycles
  def index
    @order_cycles = OrderCycle.all
  end

  # GET /order_cycles/1
  def show
  end

  # GET /order_cycles/new
  def new
    @order_cycle = OrderCycle.new
  end

  # GET /order_cycles/1/edit
  def edit
  end

  # POST /order_cycles
  def create
    @order_cycle = OrderCycle.new(order_cycle_params)

    if @order_cycle.save
      redirect_to @order_cycle, notice: 'Order cycle was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /order_cycles/1
  def update
    if @order_cycle.update(order_cycle_params)
      redirect_to @order_cycle, notice: 'Order cycle was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /order_cycles/1
  def destroy
    @order_cycle.destroy
    redirect_to order_cycles_url, notice: 'Order cycle was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_cycle
      @order_cycle = OrderCycle.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def order_cycle_params
      params.require(:order_cycle).permit(:name, :start, :end)
    end
end
