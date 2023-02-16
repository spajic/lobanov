# # frozen_string_literal: true
# 
# require 'spec_helper'
# 
# RSpec.describe Lobanov::Support::ExpandRefs do 
#   let(:subject) do 
#     Lobanov::Support::ExpandRefs.call(schema, current_folder)
#   end
# 
#   describe 'call' do
#     let(:current_folder) { 'spec/fixtures/bundle_schema/examples/verbose' }
#     let(:schema) { YAML.load_file(current_folder + '/index.yaml') } 
#     let(:etalon) { YAML.load_file(current_folder + '/verbose_etalon.yaml') }
#     it 'returns expected etalon result' do 
#       if subject != etalon
#         File.write('subject.yaml', subject.to_yaml)
#         File.write('etalon.yaml', etalon.to_yaml)
#         puts "subject and etalon are different. See subject.yaml and etalon.yaml"
#       end
#       expect(subject).to eq(etalon)
#     end
#   end
# end
