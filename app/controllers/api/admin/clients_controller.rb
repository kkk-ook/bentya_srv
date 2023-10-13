class Api::Admin::ClientsController < ApplicationController
    before_action :authenticate_api_administrator!
    #--------------------------------------------------
    #  顧客一覧
    #  GET /api/admin/clients
    #--------------------------------------------------
    def index
        params[:limit] ? limit = params[:limit].to_i : limit = nil
        params[:offset] ? offset = params[:offset].to_i : offset = 0
        clients = Client.preload(:delivery_locations, :client_product_settings).order(:created_at)
        all_count = clients.length
        clients = clients.limit(limit).offset(offset) if limit.present?
        render json: { all_count: all_count, clients: clients }, include: [:delivery_locations, :client_product_settings], status: 200
    end

    #--------------------------------------------------
    #  顧客登録
    #  POST /api/admin/clients
    #--------------------------------------------------
    def create
        Client.transaction do
            client = Client.new(client_params)
            if client.save
                # 納品場所が一箇所しかない場合、顧客名と同じ名前で作成
                if client_params[:delivery_locations_attributes].blank?
                    client.delivery_locations.create(name: client.name)
                end
                render json: { success: true }, status: 200
            else
                render json: { errors: client.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    #  顧客編集
    #  GET /api/admin/clients/:id/edit
    #--------------------------------------------------
    def edit
        client = Client.preload(:delivery_locations, :client_product_settings).find(params[:id])
        render json: { client: client }, include: [:delivery_locations, :client_product_settings], status: 200
    end

    #--------------------------------------------------
    #  顧客編集
    #  PUT /api/admin/clients/:id
    #--------------------------------------------------
    def update
        Client.transaction do
            client = Client.find(params[:id])
            if client.update(client_params)
                client.delivery_locations_discard(params)
                render json: { success: true }, status: 200
            else
                render json: { errors: client.errors.full_messages }, status: :unprocessable_entity
            end
        end
    end

    #--------------------------------------------------
    # 顧客削除
    # DELETE /api/admin/clients/:id
    #--------------------------------------------------
    def destroy
        client = Client.find(params[:id])
        client.discard!
        render json: { success: true }, status: 200
    end

    #--------------------------------------------------
    #  顧客検索
    #  GET /api/admin/clients/search
    #--------------------------------------------------
    def search
        clients = Client.preload(:delivery_locations, :client_product_settings).order(:created_at)
        clients = clients.where('company_name LIKE ?', "%#{params[:company_name]}%") if params[:company_name].present?
        clients = clients.where(code: params[:code]) if params[:code].present?
        if params[:created_at_1].present?
            created_at_1 = Date.parse(params[:created_at_1])
            clients = clients.where('created_at >= ?', created_at_1.to_s)
        end
        if params[:created_at_2].present?
            created_at_2 = Date.parse(params[:created_at_2]) + 1.day
            clients = clients.where('created_at <= ?', created_at_2.to_s)
        end

        response = {
            created_at_1: params[:created_at_1],
            created_at_2: params[:created_at_2],
            clients: clients
        }
        render json: response, include: :delivery_locations, status: 200
    end

    private
    def client_params
        params
        .require(:client)
        .permit(
            :code, :name, :company_name, :postal_code, :prefecture, :address1, :address2, :tel, :staff_1, :staff_2, :staff_3, :memo,
            delivery_locations_attributes: [:id, :name],
            client_product_settings_attributes: [:id, :product_id, :price, :is_public]
        )
    end
end
