class Account < ActiveRecord::Base
    def self.get_saml_settings(url_base)
      # this is just for testing purposes.
      # should retrieve SAML-settings based on subdomain, IP-address, NameID or similar
      settings = OneLogin::RubySaml::Settings.new
  
      # When disabled, saml validation errors will raise an exception.
      settings.soft = true
  
      #SP section
      settings.issuer                         = ENV["SP_ISSUER"]
      settings.assertion_consumer_service_url = ENV["SP_ACS_URL"]
      settings.assertion_consumer_logout_service_url = ENV["SP_LOGOUT"]
      settings.certificate = File.read(Rails.root.join('config', ENV["SP_CERT"]))
      settings.private_key = File.read(Rails.root.join('config', ENV["SP_CERT_KEY"]))
  
      # IdP section
      settings.idp_entity_id                  = ENV["IDP_ISSUER"]
      settings.idp_sso_target_url             = ENV["IDP_SSO_URL"]
      settings.idp_slo_target_url             = ENV["IDP_SLO_URL"]
      settings.idp_cert                       = File.read(Rails.root.join('config', ENV["IDP_CERT"]))
    
      settings.name_identifier_format         = ENV["IDP_ID_FORMT"]
  
      # Security section
      settings.security[:authn_requests_signed] = true
      settings.security[:logout_requests_signed] = true
      settings.security[:logout_responses_signed] = true
      settings.security[:metadata_signed] = true
      settings.security[:digest_method] = XMLSecurity::Document::SHA256
      settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256
  
      settings
    end
  end
