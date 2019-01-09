require 'spec_helper'
require 'omniauth-azure-oauth2'

module OmniAuth
  module Strategies
    module JWT; end
  end
end

describe OmniAuth::Strategies::AzureOauth2 do
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {}) }
  let(:app) {
    lambda do
      [200, {}, ["Hello."]]
    end
  }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe 'static configuration' do
    let(:options) { @options || {} }
    subject do
      OmniAuth::Strategies::AzureOauth2.new(app, {client_id: 'id', client_secret: 'secret', tenant_id: 'tenant'}.merge(options))
    end

    describe '#client' do
      it 'has correct authorize url' do
        expect(subject.client.options[:authorize_url]).to eql('https://login.windows.net/tenant/oauth2/authorize')
      end

      it 'has correct authorize params' do
        subject.client
        expect(subject.authorize_params[:domain_hint]).to be_nil
      end

      it 'has correct token url' do
        expect(subject.client.options[:token_url]).to eql('https://login.windows.net/tenant/oauth2/token')
      end

      it 'has correct token params' do
        subject.client
        expect(subject.token_params[:resource]).to eql('00000002-0000-0000-c000-000000000000')
      end

      describe "overrides" do
        it 'should override domain_hint' do
          @options = {domain_hint: 'hint'}
          subject.client
          expect(subject.authorize_params[:domain_hint]).to eql('hint')
        end
      end
    end

  end

  describe 'static common configuration' do
    let(:options) { @options || {} }
    subject do
      OmniAuth::Strategies::AzureOauth2.new(app, {client_id: 'id', client_secret: 'secret'}.merge(options))
    end

    describe '#client' do
      it 'has correct authorize url' do
        expect(subject.client.options[:authorize_url]).to eql('https://login.windows.net/common/oauth2/authorize')
      end

      it 'has correct token url' do
        expect(subject.client.options[:token_url]).to eql('https://login.windows.net/common/oauth2/token')
      end
    end
  end

  describe 'dynamic configuration' do
    let(:provider_klass) {
      Class.new {
        def initialize(strategy)
        end

        def client_id
          'id'
        end

        def client_secret
          'secret'
        end

        def tenant_id
          'tenant'
        end

      }
    }

    subject do
      OmniAuth::Strategies::AzureOauth2.new(app, provider_klass)
    end

    describe '#client' do
      it 'has correct authorize url' do
        expect(subject.client.options[:authorize_url]).to eql('https://login.windows.net/tenant/oauth2/authorize')
      end

      it 'has correct authorize params' do
        subject.client
        expect(subject.authorize_params[:domain_hint]).to be_nil
      end

      it 'has correct token url' do
        expect(subject.client.options[:token_url]).to eql('https://login.windows.net/tenant/oauth2/token')
      end

      it 'has correct token params' do
        subject.client
        expect(subject.token_params[:resource]).to eql('00000002-0000-0000-c000-000000000000')
      end

      # todo: how to get this working?
      # describe "overrides" do
      #   it 'should override domain_hint' do
      #     provider_klass.domain_hint = 'hint'
      #     subject.client
      #     expect(subject.authorize_params[:domain_hint]).to eql('hint')
      #   end
      # end
    end

  end

  describe 'dynamic common configuration' do
    let(:provider_klass) {
      Class.new {
        def initialize(strategy)
        end

        def client_id
          'id'
        end

        def client_secret
          'secret'
        end
      }
    }

    subject do
      OmniAuth::Strategies::AzureOauth2.new(app, provider_klass)
    end

    describe '#client' do
      it 'has correct authorize url' do
        expect(subject.client.options[:authorize_url]).to eql('https://login.windows.net/common/oauth2/authorize')
      end

      it 'has correct token url' do
        expect(subject.client.options[:token_url]).to eql('https://login.windows.net/common/oauth2/token')
      end
    end
  end

  describe "raw_info" do
    subject do
      OmniAuth::Strategies::AzureOauth2.new(app, {client_id: 'id', client_secret: 'secret'})
    end

    let(:token) do
      JWT.encode({"some" => "payload"}, "secret")
    end

    let(:access_token) do
      double(:token => token)
    end

    before :each do
      allow(subject).to receive(:access_token) { access_token }
    end

    it "does not clash if JWT strategy is used" do
      expect do
        subject.info
      end.to_not raise_error
    end
  end
end
