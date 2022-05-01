class SamlController < ApplicationController
    skip_before_action :verify_authenticity_token, :only => [:acs, :logout]
    
    # =========================================================
    #
    # =========================================================
    def index
      
      @attrs = {}
    end
  
    # =========================================================
    # GET /saml/sso
    # 画面からSAML Login押下時にリクエスト
    # =========================================================
    def sso
      # 
      settings = Account.get_saml_settings(get_url_base)
      if settings.nil?
        render :action => :no_settings
        return
      end
      
      # SAMLリクエストを生成し、HTTPリダイレクトを実施
      request = OneLogin::RubySaml::Authrequest.new
      redirect_to(request.create(settings),  allow_other_host: true)
  
    end
  
    # =========================================================
    #　POST /saml/acs
    # =========================================================
    def acs
      # 
      #logger.info params
      settings = Account.get_saml_settings(get_url_base)
      response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => settings)
      
      #
      if response.is_valid?
        session[:nameid] = response.nameid
        session[:attributes] = response.attributes
        @attrs = session[:attributes]
        logger.info "Sucessfully logged"
        logger.info "NAMEID: #{response.nameid}"
        
        # redirect
        redirect_to "/saml"
      else
        logger.info "Response Invalid. Errors: #{response.errors}"
        @errors = response.errors
        render :action => :fail
      end
    end
  
    # =========================================================
    # GET /saml/metadata
    # SP側のメタデータ生成
    # =========================================================
    def metadata
      settings = Account.get_saml_settings(get_url_base)
      meta = OneLogin::RubySaml::Metadata.new
      render :xml => meta.generate(settings, true)
    end
  
    # =========================================================
    # GET  /saml/logout
    # POST /saml/logout
    # =========================================================
    # SPのログアウト処理
    def logout
      if params[:SAMLRequest]
        # よばれんかも
        return idp_logout_request
  
      elsif params[:SAMLResponse]
        # IDPからのログアウト結果を取得
        return process_logout_response
      elsif params[:slo]
        # シングルサインアウトを実施するため、IDPへリダイレクトする
        return sp_logout_request
      else
        # SPのみログアウト(セッション消去)
        reset_session
      end
    end
  
    # =========================================================
    #　SPよりシングルサインアウトを開始するため、IDPへリダイレクト
    # =========================================================
    def sp_logout_request
      # LogoutRequest accepts plain browser requests w/o paramters
      settings = Account.get_saml_settings(get_url_base)
  
      if settings.idp_slo_target_url.nil?
        logger.info "SLO IdP Endpoint not found in settings, executing then a normal logout'"
        reset_session
      else
  
        # Since we created a new SAML request, save the transaction_id
        # to compare it with the response we get back
        logout_request = OneLogin::RubySaml::Logoutrequest.new()
        session[:transaction_id] = logout_request.uuid
        logger.info "New SP SLO for User ID: '#{session[:nameid]}', Transaction ID: '#{session[:transaction_id]}'"
  
        if settings.name_identifier_value.nil?
          settings.name_identifier_value = session[:nameid]
        end
  
        relayState = url_for controller: 'saml', action: 'index'
        redirect_to(logout_request.create(settings, :RelayState => relayState),  allow_other_host: true)
      end
    end
  
    # =========================================================
    # IDPからのログアウトレスポンスより結果を返却
    # =========================================================
    # After sending an SP initiated LogoutRequest to the IdP, we need to accept
    # the LogoutResponse, verify it, then actually delete our session.
    def process_logout_response
      settings = Account.get_saml_settings(get_url_base)
      request_id = session[:transaction_id]
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings, :matches_request_id => request_id, :get_params => params)
      logger.info "LogoutResponse is: #{logout_response.response.to_s}"
  
      # Validate the SAML Logout Response
      if not logout_response.validate
        error_msg = "The SAML Logout Response is invalid.  Errors: #{logout_response.errors}"
        logger.error error_msg
        render :inline => error_msg
      else
        # Actually log out this session
        if logout_response.success?
          logger.info "Delete session for '#{session[:nameid]}'"
          reset_session
        end
      end
    end
  
    # =========================================================
    #
    # =========================================================
    # Method to handle IdP initiated logouts
    def idp_logout_request
      settings = Account.get_saml_settings(get_url_base)
      logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest], :settings => settings)
      if not logout_request.is_valid?
        error_msg = "IdP initiated LogoutRequest was not valid!. Errors: #{logout_request.errors}"
        logger.error error_msg
        render :inline => error_msg
      end
      logger.info "IdP initiated Logout for #{logout_request.nameid}"
  
      # Actually log out this session
      reset_session
  
      logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(settings, logout_request.id, nil, :RelayState => params[:RelayState])
      redirect_to logout_response
    end
  
    # =========================================================
    #
    # =========================================================
    def get_url_base
      "#{request.protocol}#{request.host_with_port}"
    end
  
  end
