require 'spec_helper'

describe Todoable::Item do
  let(:item) { described_class.new(attributes) }
  let(:list) { instance_double(Todoable::List, id: 'list-sha-id', items: []) }

  let(:attributes) do
    {
      id: id,
      src: src,
      name: name,
      list: list,
      finished_at: finished_at
    }
  end

  let(:id) { 'sha-id' }
  let(:src) { 'path-to-resource' }
  let(:name) { 'Todo Item' }
  let(:finished_at) { Time.now.to_s } # different format is returned from server

  describe '#create' do
    subject(:create) { item.create }

    let(:path) { described_class.path(list) }
    let(:payload) { { item: { name: name } } }

    before do
      stub_request(:post, path)
        .to_return(status: 201, body: payload[:item].to_json)

      allow(Todoable.client).to receive(:post).and_call_original
    end


    context 'when the item has an id' do
      it 'raises' do
        expect { create }.to raise_error(Todoable::TodoableError)
      end
    end

    context 'when the item does not have an id' do
      let(:id) { nil }

      it 'creates the item' do
        create
        expect(Todoable.client).to have_received(:post)
          .with(path, payload.to_json)
      end

      it 'adds the item to the list\'s item attribute' do
        expect { create }.to change { list.items.count }.by(1)
      end
    end
  end

  describe '#destroy' do
    subject(:delete) { item.destroy }

    let(:path) { item.path }

    context 'when the response is successful' do
      before do
        stub_request(:delete, path)
          .to_return(status: 204)

        allow(Todoable.client).to receive(:delete).and_call_original
      end

      it 'deletes the item' do
        delete
        expect(Todoable.client).to have_received(:delete).with(path)
      end

      it { is_expected.to eq(true) }
    end
  end

  describe '#finish!' do
    subject(:finish!) { item.finish! }

    let(:path) { "#{item.path}/finish" }

    before do
      stub_request(:put, path)
        .to_return(status: 200)

      allow(Todoable.client).to receive(:put).and_call_original
    end

    it 'marks the item as finished' do
      finish!
      expect(Todoable.client).to have_received(:put).with(path)
    end

    it { is_expected.to eq(true) }
  end
end
