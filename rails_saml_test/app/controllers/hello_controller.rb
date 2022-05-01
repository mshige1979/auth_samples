class HelloController < ApplicationController
    def index
        logger.info session[:nameid]
        logger.info session[:attributes]
        render plain: "index"
    end
end
