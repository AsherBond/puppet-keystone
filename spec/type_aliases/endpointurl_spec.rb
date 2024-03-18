require 'spec_helper'

describe 'Keystone::EndpointUrl' do
  describe 'valid types' do
    context 'with valid types' do
      [
        'http://127.0.0.1:5000',
        'https://[::1]:5000',
        'ws://127.0.0.1:5000',
        'wss://[::1]:5000',
        ''
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        'ftp://127.0.0.1:5000',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
