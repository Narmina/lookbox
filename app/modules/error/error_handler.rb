module Error
  module ErrorHandler
    def self.included(clazz)
      clazz.class_eval do
          rescue_from StandardError, :with => :render_error
          rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
          rescue_from ActionController::RoutingError, :with => :render_not_found
          rescue_from ActionController::UnknownController, :with => :render_not_found
      end
    end

    private

    def render_not_found(e)
      Bugsnag.notify(e)
      @exception = ErrorStruct.new(e, 404)
      render @exception.view_path
    end

    def render_error(e)
      Bugsnag.notify(e)
      @exception = ErrorStruct.new(e, 500)
      render @exception.view_path
    end

  end

  class ErrorStruct
    attr_accessor :status, :type, :message

    def initialize(e, status)
      @status = status
      @type = e.class.to_s
      @message = e.message
    end

    def view_path
      "error/#{@status == 404 ? 'not_found_handler' : 'error_handler'}"
    end

  end

end
