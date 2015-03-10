require 'timecop'
require_relative '../lib/status_parser'

describe Status do
  context "with a sample status file" do
    let(:xml) { File.read(File.join('spec', 'fixtures', 'passenger-status --show=xml')) }

    it "should parse the xml file" do
      Status.new(xml)
    end

    context "that is parsed" do
      let(:status) { Status.new(xml) }

      it "should return the correct general info" do
        expect(status.processes_max).to eq 6
        expect(status.processes_current).to eq 3
      end

      it "collects CPU information" do
        expect(status.cpu_total).to eq 4.5
        expect(status.cpu_per_process).to eq({23882 => 1.0, 23892 => 1.5, 23902 => 2.0, 23912 => 0.0, 23922 => 0.0, 23932 => 0.0})
      end

      it "collects memory information" do
        expect(status.memory_total).to eq 262
        expect(status.memory_per_process).to eq({23882=>54, 23892=>31, 23902=>36, 23912=>30, 23922=>55, 23932=>56})
      end

      it "collects usage timings" do
        Timecop.freeze(Date.new(2014, 3, 15)) do
          expect(status.last_used_time_per_process).to eq({23882=>379736, 23892=>386339, 23902=>382567, 23912=>386338, 23922=>379151, 23932=>377501})
          expect(status.uptime_per_process).to eq({23882=>386339, 23892=>386339, 23902=>386339, 23912=>386338, 23922=>386338, 23932=>386338})
        end
      end

      it "collects request information" do
        expect(status.request_queue_size).to eq 3
      end

    end

  end
end
