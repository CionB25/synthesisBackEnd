class API::V1::SongsController < ApplicationController
  def index
    render json: Song.all
  end
end
