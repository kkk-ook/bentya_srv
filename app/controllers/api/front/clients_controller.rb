class Api::Front::ClientsController < ApplicationController
    #--------------------------------------------------
    #  顧客一覧
    #  GET /api/front/clients
    #--------------------------------------------------
    def index
        clients = Client.preload(:delivery_locations, :client_product_settings).order(:created_at)
        all_count = clients.length

        clients = clients.map do |client|
            delivery_location_hashes = client.delivery_locations.map do |delivery_location|
                {
                    delivery_location_id: delivery_location.id,
                    delivery_location_name: delivery_location.name
                }
            end

            {
                id: client.id,
                code: client.code,
                name: client.name,
                delivery_locations: delivery_location_hashes
            }
        end

        render json: { all_count: all_count, clients: clients }, include: [:delivery_locations, :client_product_settings], status: 200
    end

end
