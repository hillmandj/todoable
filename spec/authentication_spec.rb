require 'spec_helper'

describe Todoable::Authentication do
  subject(:authentication) do
    described_class.new(
      username: username,
      password: password,
      base_url: base_url
    )
  end

  let(:username) { 'username' }
  let(:password) { 'password' }
  let(:base_url) { 'http://todoable.teachable.tech/api/' }
  let(:auth_url) { base_url + 'authenticate' }

  describe '#fetch_token' do
    subject(:fetch_token) { authentication.fetch_token }

    # Emulates what really happens when building Basic Auth headers
    let(:token) { Base64.encode64("#{username}:#{password}") }

    context 'with successful authentication' do
      let(:token_response) { { 'token' => token }.to_json }

      before do
        stub_request(:post, auth_url).with(basic_auth: [username, password])
          .to_return(status: 200, body: token_response)
      end

      it { is_expected.to eq(token) }
    end

    context 'with unsuccessful authentication' do
      before do
        stub_request(:post, auth_url).with(basic_auth: [username, password])
          .to_return(status: 401)
      end

      it { is_expected.to be_nil }
    end
  end
end
