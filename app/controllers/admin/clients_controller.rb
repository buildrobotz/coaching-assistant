module Admin
  class ClientsController < Admin::BaseController
    before_action :set_client, only: [:show, :edit, :update, :destroy]

    def index
      @clients = Client.order(:name)
    end

    def show
    end

    def new
      @client = Client.new
      @timezones = ActiveSupport::TimeZone.all.map { |tz| [tz.name, tz.name] }
    end

    def create
      @client = Client.new(client_params)

      if @client.save
        flash[:success] = "Client created successfully!"
        redirect_to admin_client_path(@client)
      else
        @timezones = ActiveSupport::TimeZone.all.map { |tz| [tz.name, tz.name] }
        render :new
      end
    end

    def edit
      @timezones = ActiveSupport::TimeZone.all.map { |tz| [tz.name, tz.name] }
    end

    def update
      if @client.update(client_params)
        flash[:success] = "Client updated successfully!"
        redirect_to admin_client_path(@client)
      else
        @timezones = ActiveSupport::TimeZone.all.map { |tz| [tz.name, tz.name] }
        render :edit
      end
    end

    def destroy
      @client.destroy
      flash[:success] = "Client deleted successfully!"
      redirect_to admin_clients_path
    end

    private

    def set_client
      @client = Client.find(params[:id])
    end

    def client_params
      params.require(:client).permit(:name, :email, :timezone, :preferred_send_time)
    end
  end
end
