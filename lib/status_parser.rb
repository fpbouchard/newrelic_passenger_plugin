class Status
  require 'date'

  def initialize(output)
    status_command = output.match(/<.+/m).to_s
    doc = Nokogiri::XML(status_command,nil,'iso8859-1')

    @status_result = [
      doc.xpath('//info/max').text.to_i,
      doc.xpath('//info/capacity_used').text.to_i,
      doc.xpath('//info/get_wait_list_size').text.to_i,
      parse_sessions(doc),
      parse_cpu(doc),
      parse_app_memory(doc),
      parse_last_used(doc)
    ]
  end

  def max
    @status_result[0]
  end

  def current
    @status_result[1]
  end

  def queue
    @status_result[2]
  end

  def sessions
    @status_result[3]
  end

  def cpu
    @status_result[4]
  end

  def process_memory
    @status_result[5]
  end

  def last_used_time
    @status_result[6]
  end

  private

  def parse_sessions(doc)
    sessions_total = 0
    doc.xpath('//process/sessions').each do |x|
      sessions_total += x.text.to_i
    end
    sessions_total
  end

  def parse_cpu(doc)
    cpu_total = 0
    doc.xpath('//process/cpu').each do |x|
      cpu_total += x.text.to_f
    end
    cpu_total
  end

  def parse_app_memory(doc)
    processes = Hash.new(0)
    doc.xpath('//process').each_with_index do |x, index|
      processes[(index + 1).to_s] += x.xpath('./real_memory').text.to_i / 1024
    end
    processes
  end

  def parse_last_used(doc)
    processes = Hash.new(0)
    doc.xpath('//process').each_with_index do |x, index|
      unix_stamp = (x.xpath('./last_used').text.to_i / 1000000)
      elapsed = Time.now.to_i - unix_stamp
      processes[(index + 1).to_s] = elapsed
    end
    processes
  end

end
