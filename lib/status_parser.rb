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
    cpu_total = 0
    cpu_per_process = {}
    doc.xpath('//process').each do |process_node|
      pid = process_node.xpath('pid').text.to_i
      this_cpu = process_node.xpath('cpu').text.to_f
      cpu_total += this_cpu
      cpu_per_process[pid] = this_cpu
    end
    self.cpu_total = cpu_total
    self.cpu_per_process = cpu_per_process
  end

  def parse_memory(doc)
    mem_total = 0
    processes = {}
    doc.xpath('//process').each do |process_node|
      pid = process_node.xpath('pid').text.to_i
      this_mem = process_node.xpath('./real_memory').text.to_i / 1024
      mem_total += this_mem
      processes[pid] = this_mem
    end
    self.memory_per_process = processes
    self.memory_total = mem_total
  end

  def parse_last_used(doc)
    processes = {}
    doc.xpath('//process').each do |process_node|
      pid = process_node.xpath('pid').text.to_i
      unix_stamp = (process_node.xpath('./last_used').text.to_i / 1000000)
      elapsed = Time.now.to_i - unix_stamp
      processes[pid] = elapsed
    end
    self.last_used_time_per_process = processes
  end

  def parse_uptime(doc)
    processes = {}
    doc.xpath('//process').each do |process_node|
      pid = process_node.xpath('pid').text.to_i
      unix_stamp = (process_node.xpath('./spawn_end_time').text.to_i / 1000000)
      elapsed = Time.now.to_i - unix_stamp
      processes[pid] = elapsed
    end
    self.uptime_per_process = processes
  end

  def parse_requests(doc)
    self.request_queue_size = doc.xpath('//info/get_wait_list_size').text.to_i

    requests_total = 0
    processes = {}
    doc.xpath('//process').each do |process_node|
      pid = process_node.xpath('pid').text.to_i
      requests = process_node.xpath('./processed').text.to_i
      requests_total += requests
      processes[pid] = requests
    end

    self.requests_total = requests_total
    self.requests_per_process = processes
  end

end
