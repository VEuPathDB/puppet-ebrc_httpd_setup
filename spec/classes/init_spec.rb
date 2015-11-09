require 'spec_helper'
describe 'ebrc_httpd_setup' do

  context 'with defaults for all parameters' do
    it { should contain_class('ebrc_httpd_setup') }
  end
end
