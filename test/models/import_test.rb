# == Schema Information
#
# Table name: imports
#
#  id               :integer          not null, primary key
#  equipment        :string(255)
#  quantity         :integer
#  from             :string(255)
#  to               :string(255)
#  bl_number        :string(255)
#  estimate_arrival :date
#  description      :string(255)
#  rate             :string(255)
#  status           :string(255)
#  out_of_port_date :date
#  customer_id      :integer
#  created_at       :datetime
#  updated_at       :datetime
#

require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  setup do
    @import = FactoryGirl.create :import
  end

  test "Bl number must be unique" do
    import1 = Import.new(to: 'a', from: 'b', weight: 3, rate_agreed: 1200)
    import1.bl_number = 'BL_NUMBER1'
    assert import1.save

    import2 = Import.new(to: 'a', from: 'b', weight: 3, rate_agreed: 3000)
    import2.bl_number = 'BL_NUMBER1'
    assert_not import2.save
    assert import2.errors.messages[:bl_number].include?(
                      'has already been taken')
  end

  test 'should set the clearing agent' do
    clearing_agent = FactoryGirl.create(:vendor)
    @import.clearing_agent_id = clearing_agent.id
    assert_equal @import.clearing_agent, clearing_agent.name
  end

  test 'must assigned work order number before ready to load' do
    @import.status = 'copy_documents_received' 
    @import.original_documents_received!
    @import.container_discharged!
    assert_raises(AASM::InvalidTransition) do
      @import.ready_to_load!
    end
  end
end
