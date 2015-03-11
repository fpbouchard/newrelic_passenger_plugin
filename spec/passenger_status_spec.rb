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
        expect(status.cpu_per_worker).to eq({0 => 1.0, 1 => 1.5, 2 => 2.0, 3 => 0.0, 4 => 0.0, 5 => 0.0})
      end

      it "collects memory information" do
        expect(status.memory_total).to eq 262
        expect(status.memory_per_worker).to eq({0=>54, 1=>31, 2=>36, 3=>30, 4=>55, 5=>56})
      end

      it "collects usage timings" do
        Timecop.freeze(Date.new(2014, 3, 15)) do
          expect(status.last_used_time_per_worker).to eq({0=>379736, 1=>386339, 2=>382567, 3=>386338, 4=>379151, 5=>377501})
          expect(status.uptime_per_worker).to eq({0=>386339, 1=>386339, 2=>386339, 3=>386338, 4=>386338, 5=>386338})
        end
      end

      it "collects request information" do
        expect(status.request_queue_size).to eq 3
        expect(status.requests_total).to eq 3257
        expect(status.requests_per_worker).to eq({0=>1808, 1=>0, 2=>1, 3=>0, 4=>327, 5=>1121})
      end

    end

  end
end
