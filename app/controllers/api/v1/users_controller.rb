BASE_URL = "http://localhost:3001"

class Api::V1::UsersController < ApplicationController
  def index
    render json: User.all
  end

  def create
    body = {
      grant_type: "authorization_code",
      code: params[:code],
      redirect_uri: ENV["REDIRECT_URI"],
      client_id: ENV["CLIENT_ID"],
      client_secret: ENV["CLIENT_SECRET"]
    }

    auth_response = RestClient.post("https://accounts.spotify.com/api/token", body)
    auth_params = JSON.parse(auth_response.body)

    header = {
      Authorization: "Bearer #{auth_params["access_token"]}"
    }

    user_response = RestClient.get('https://api.spotify.com/v1/me', header)
    user_params = JSON.parse(user_response.body)


    @user = User.find_or_create_by(
      username: user_params["id"],
      spotify_url: user_params["external_urls"]["spotify"],
      href: user_params["href"],
      uri: user_params["uri"]
    )

    payload = {:access_token => auth_params["access_token"]}
    token = JWT.encode payload, ENV["MY_SECRET"], ENV["ES"]

    @user.update(
      access_token: token
    )

    render json: {username: @user.username, code: @user.access_token}
  end
end
