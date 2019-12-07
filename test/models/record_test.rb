require 'test_helper'

class RecordTest < ActiveSupport::TestCase
  test 'validation' do
    record = Record.new(valid_params)
    assert record.valid?

    record = Record.new(valid_params.merge(date: nil))
    assert record.invalid?

    record = Record.new(valid_params.merge(cost: nil))
    assert record.invalid?
    record = Record.new(valid_params.merge(cost: -1))
    assert record.invalid?
    record = Record.new(valid_params.merge(cost: 3.14))
    assert record.invalid?
  end

  test 'create_self_and_transports' do
    record = Record.new(valid_params)
    assert record.hospital.hospital_transports

    assert ret = record.create_self_and_transports
    assert_equal 3, ret.size
    assert_equal hospitals(:hospital1), ret.first.hospital
    assert_equal transports(:transport1), ret.second.transport
    assert_equal transports(:transport2), ret.third.transport
  end

  test 'create_self_and_transports without hospital_transports' do
    record = Record.new(valid_params.merge(division: hospitals(:hospital2)))
    assert record.hospital.hospital_transports.blank?

    assert ret = record.create_self_and_transports
    assert_equal 1, ret.size
    assert_equal hospitals(:hospital2), ret.first.hospital
  end

  test 'create_self_and_transports invalid_record' do
    record = Record.new(valid_params.merge(date: nil))
    assert record.invalid?

    assert_no_difference -> {Record.count} do
      assert_not record.create_self_and_transports
    end
  end

  test 'annual_statistics total cost by year' do
    Record.delete_all
    Record.create(valid_params.merge(date: Date.new(2017, 1, 1), cost: 100))
    Record.create(valid_params.merge(date: Date.new(2017, 12, 31), cost: 100))

    Record.create(valid_params.merge(date: Date.new(2018, 1, 1), cost: 200))
    Record.create(valid_params.merge(date: Date.new(2018, 12, 31), cost: 200))

    Record.create(valid_params.merge(date: Date.new(2019, 1, 1), cost: 300))
    Record.create(valid_params.merge(date: Date.new(2019, 12, 31), cost: 300))

    ret = Record.annual_statistics(2017)
    ret.each do |r|
      assert_equal 200, r.sum_cost
    end

    ret = Record.annual_statistics(2018)
    ret.each do |r|
      assert_equal 400, r.sum_cost
    end

    ret = Record.annual_statistics(2019)
    ret.each do |r|
      assert_equal 600, r.sum_cost
    end
  end

  def valid_params
    hospital1 = hospitals(:hospital1)
    person1 = people(:user1)
    {date: Time.zone.today, cost: 100,
     division_id: hospital1.id, person_id: person1.id}
  end
end
