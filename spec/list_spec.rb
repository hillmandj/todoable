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

  shared_examples_for 'a request that can refresh the auth token' do
    context 'when unauthorized' do
      let(:new_token) { 'new_token' }

      before do
        stub_request(:any, path)
          .to_return(status: 401, body: '')

        allow(Todoable.authentication).to receive(:fetch_token).and_return(new_token)
      end

      it 'attempts to fetch another token' do
        subject
        expect(Todoable.authentication).to have_received(:fetch_token)
      end
    end
  end

  describe '.all' do
    subject(:get_lists) { described_class.all }

    let(:path) { described_class.path }

    let(:list_response) do
      {
        "name": "Urgent Things",
        "src":  "http://todoable.teachable.tech/api/lists/id1",
        "id":   "id1"
      }
    end

    # Server doesn't seem to return items in the response for GET /lists
    # However, it does on the member route, so this illustrates how it would
    # still construct Todoable::Item(s)
    let(:list_with_items_response) do
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
      { "lists": [list_response, list_with_items_response] }.to_json
    end

    it_behaves_like 'a request that can refresh the auth token'

    context 'when the request is valid' do
      before do
        stub_request(:get, path)
          .to_return(status: 200, body: response_body)
      end

      it 'makes the request' do
        allow(Todoable.client).to receive(:get).and_call_original
        get_lists
        expect(Todoable.client).to have_received(:get).with(path)
      end

      it { is_expected.to all(be_a(Todoable::List)) }

      it do
        is_expected.to match_array([
          have_attributes(
            id: list_response[:id],
            src: list_response[:src],
            name: list_response[:name]
          ),
          have_attributes(
            id: list_with_items_response[:id],
            src: list_with_items_response[:src],
            name: list_with_items_response[:name],
            items: all(be_a(Todoable::Item))
          )
        ])
      end
    end
  end

  describe '.find' do
    subject(:find) { described_class.find(id) }

    let(:path) { list.path }

    let(:list_response) do
      {
        "name": list.name,
        "items": [
          {
            "name":         "Feed the cat",
            "finished_at":  "null",
            "src":          "http://todoable.teachable.tech/api/lists/#{id}/items/item-sha-id-1",
            "id":           "item-sha-id-1"
          }, {
            "name":        "Get cat food",
            "finished_at": "null",
            "src":         "http://todoable.teachable.tech/api/lists/#{id}/items/item-sha-id-2",
            "id":          "item-sha-id-2"
          }
        ]
      }
    end

    before do
      stub_request(:get, path)
        .to_return(status: 200, body: list_response.to_json)
    end

    it_behaves_like 'a request that can refresh the auth token'

    it { is_expected.to be_a(Todoable::List) }

    it do
      is_expected.to have_attributes(
        name: list_response[:name],
        items: all(be_a(Todoable::Item))
      )
    end

    it 'sets the items on the list object' do
      expect(find.items).to match_array([
        have_attributes(list_response[:items].first),
        have_attributes(list_response[:items].last)
      ])
    end
  end

  describe '#create' do
    subject(:create) { list.create }

    let(:path) { described_class.path }
    let(:payload) { { list: { name: name } } }

    before do
      stub_request(:post, path)
        .to_return(status: 201, body: payload[:list].to_json)

      allow(Todoable.client).to receive(:post).and_call_original
    end

    context 'when a list object is instantiated with an id' do
      it 'raises' do
        expect { create }.to raise_error(Todoable::InvalidRequestError)
      end
    end

    context 'when a list object is instantiated without an id' do
      let(:id) { nil }

      it_behaves_like 'a request that can refresh the auth token'

      it 'creates the list' do
        create
        expect(Todoable.client).to have_received(:post)
          .with(path, payload.to_json)
      end

      it { is_expected.to be_a(Todoable::List) }
    end
  end

  describe '#update' do
    subject(:update) { list.update }

    let(:new_name) { 'New Name' }
    let(:path) { list.path }
    let(:payload) { { list: { name: new_name } } }

    before do
      list.name = new_name
    end

    it_behaves_like 'a request that can refresh the auth token'

    context 'when the response is successful' do
      before do
        stub_request(:patch, path)
          .to_return(status: 200, body: payload[:list].to_json)

        allow(Todoable.client).to receive(:patch).and_call_original
      end

      it 'updates the list' do
        update
        expect(Todoable.client).to have_received(:patch)
          .with(path, payload.to_json)
      end
    end
  end

  describe '#destroy' do
    subject(:delete) { list.destroy }

    let(:path) { list.path }

    context 'when the response is successful' do
      before do
        stub_request(:delete, path)
          .to_return(status: 201)

        allow(Todoable.client).to receive(:delete).and_call_original
      end

      it_behaves_like 'a request that can refresh the auth token'

      it 'deletes the list' do
        delete
        expect(Todoable.client).to have_received(:delete).with(path)
      end

      it { is_expected.to eq(true) }
    end
  end

  describe '#add_item' do
    subject(:add_item) { list.add_item(name) }

    let(:name) { 'Item Name' }
    let(:item) { instance_double(Todoable::Item) }

    before do
      allow(Todoable::Item).to receive(:new).and_return(item)
      allow(item).to receive(:create).and_return(item)
    end

    it_behaves_like 'a request that can refresh the auth token'

    it 'instantiates an Item object' do
      add_item
      expect(Todoable::Item).to have_received(:new).with(list: list, name: name)
    end

    it 'calls create on the Item' do
      add_item
      expect(item).to have_received(:create)
    end

    it 'adds the item to it\'s items attribute' do
      add_item
      expect(list.items).to include(item)
    end
  end
end
