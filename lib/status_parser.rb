class Status < OpenStruct
  require 'date'

  def initialize(output)
    status_command = output.match(/<.+/m).to_s
    doc = Nokogiri::XML(status_command,nil,'iso8859-1')

    self.processes_max = doc.xpath('//info/max').text.to_i
    self.processes_current = doc.xpath('//info/capacity_used').text.to_i

    parse_cpu(doc)
    parse_app_memory(doc)
    parse_last_used(doc)
    parse_requests(doc)
  end

  private

  def parse_cpu(doc)
    cpu_total = 0
    cpu_per_host = {}
    doc.xpath('//process/cpu').each_with_index do |x, index|
      this_cpu = x.text.to_f
      cpu_total += this_cpu
      cpu_per_host[(index + 1).to_s] = this_cpu
    end
    self.cpu_total = cpu_total
    self.cpu_per_host = cpu_per_host
  end

  def parse_app_memory(doc)
    mem_total = 0
    processes = {}
    doc.xpath('//process').each_with_index do |x, index|
      this_mem = x.xpath('./real_memory').text.to_i / 1024
      mem_total += this_mem
      processes[(index + 1).to_s] += this_mem
    end
    self.app_memory_per_process = processes
    self.app_memory_total = mem_total
  end

  def parse_last_used(doc)
    processes = {}
    doc.xpath('//process').each_with_index do |x, index|
      unix_stamp = (x.xpath('./last_used').text.to_i / 1000000)
      elapsed = Time.now.to_i - unix_stamp
      processes[(index + 1).to_s] = elapsed
    end
    self.last_used_time = processes
  end

  def parse_requests(doc)
    self.queue = doc.xpath('//info/get_wait_list_size').text.to_i

    requests_total = 0
    processes = {}
    doc.xpath('//process').each_with_index do |x, index|
      requests = x.xpath('./processed').text.to_i
      request_total += requests
      processes[(index + 1).to_s] = requests
    end

    self.requests_total = requests_total
    self.requests_per_host = processes
  end

end
