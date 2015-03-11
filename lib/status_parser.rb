require 'ostruct'
require 'nokogiri'

class Status < OpenStruct
  def initialize(output)
    super()

    status_command = output.match(/<.+/m).to_s
    doc = Nokogiri::XML(status_command,nil,'iso8859-1')

    self.processes_max = doc.xpath('//info/max').text.to_i
    self.processes_current = doc.xpath('//info/capacity_used').text.to_i

    parse_cpu(doc)
    parse_memory(doc)
    parse_last_used(doc)
    parse_uptime(doc)
    parse_requests(doc)
  end

  private

  def parse_cpu(doc)
    total = 0
    self.cpu_per_worker = Hash[doc.xpath('//process/cpu').each_with_index.collect do |node, idx|
      this_cpu = node.text.to_f
      total += this_cpu
      [idx, this_cpu]
    end]
    self.cpu_total = total
  end

  def parse_memory(doc)
    total = 0
    self.memory_per_worker = Hash[doc.xpath('//process/real_memory').each_with_index.collect do |node, idx|
      this_mem = node.text.to_i
      total += this_mem
      [idx, this_mem]
    end]
    self.memory_total = total
  end

  def parse_last_used(doc)
    self.last_used_time_per_worker = Hash[doc.xpath('//process/last_used').each_with_index.collect do |node, idx|
      unix_stamp = (node.text.to_i / 1000000)
      elapsed = Time.now.to_i - unix_stamp
      [idx, elapsed]
    end]
  end

  def parse_uptime(doc)
    self.uptime_per_worker = Hash[doc.xpath('//process/spawn_end_time').each_with_index.collect do |node, idx|
      unix_stamp = (node.text.to_i / 1000000)
      elapsed = Time.now.to_i - unix_stamp
      [idx, elapsed]
    end]
  end

  def parse_requests(doc)
    self.request_queue_size = doc.xpath('//info/get_wait_list_size').text.to_i

    total = 0
    self.requests_per_worker = Hash[doc.xpath('//process/processed').each_with_index.collect do |node, idx|
      requests = node.text.to_i
      total += requests
      [idx, requests]
    end]

    self.requests_total = total
  end

end
