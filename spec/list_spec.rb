require 'spec_helper'

describe Todoable::List do
  let(:list) { described_class.new(attributes) }

  let(:attributes) do
    {
      id: id,
      src: src,
      name: name,
      items: items
    }
  end

  let(:id) { 'sha-id' }
  let(:src) { 'path-to-resource' }
  let(:name) { 'Todo List' }
  let(:items) { [] }

  describe '.all' do
    subject(:request) { described_class.all }

    let(:path) { described_class.path }

    let(:list) do
      {
        "name": "Urgent Things",
        "src":  "http://todoable.teachable.tech/api/lists/id1",
        "id":   "id1"
      }
    end

    let(:list_with_items) do
      {
        "name": "Shopping List",
        "src":  "http://todoable.teachable.tech/api/lists/id2",
        "id":   "id2",
        "items": [
          {
            "name": "Do your homework!",
            "finished_at": "null",
            "src": "http://todoable.teachable.tech/api/lists/id2/items/id3",
            "id": 'id3'
          }
        ]
      }
    end

    let(:response_body) do
      { "lists": [list, list_with_items] }.to_json
    end

    context 'when unauthorized' do
      let(:new_token) { 'new_token' }

      before do
        stub_request(:get, path)
          .to_return(status: 401, body: { "errors": "Unauthorized" }.to_json)

        allow(Todoable.authentication).to receive(:fetch_token).and_return(new_token)
      end

      it 'attempts to fetch another token' do
        request
        expect(Todoable.authentication).to have_received(:fetch_token)
      end
    end

    context 'when the request is valid' do
      before do
        stub_request(:get, path)
          .to_return(status: 200, body: response_body)
      end

      it 'calls the todoable client' do
        allow(Todoable.client).to receive(:get).and_call_original
        request
        expect(Todoable.client).to have_received(:get).with(path)
      end

      it { is_expected.to all(be_a(Todoable::List)) }
    end
  end

  describe '.find' do

  end

  describe '.create' do
  end

  describe '#update' do
    context 'when the response is successful' do
      before do
        stub_request(:put, path)
          .to_return(status: 201)
      end

      it 'updates the list' do

      end
    end
  end
end
