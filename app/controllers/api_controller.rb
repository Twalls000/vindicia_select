class ApiController < ActionController::Base
 before_action :authenticate

private

  def authenticate
    # VINDICIA_SELECT_API_KEY comes from ~/.bashrc file
    render json: { error: { code: 401, message: 'Unauthorized', errors:[] }}, status: :unauthorized unless request.headers['HTTP_API_KEY'] == GciSimpleEncryption.decrypt_hex(ENV['VINDICIA_SELECT_API_KEY'])
  end

  def json_error_response(objects)
    objects = Array(objects)
    # A single source error JSON response
    {
      error: {
        code: 412,
        message: "Input parameters aren't valid",
        errors: objects.map do |obj|
          {obj.class.name.snakecase.to_sym => obj.errors.messages}
        end
      }
    }
  end

end
