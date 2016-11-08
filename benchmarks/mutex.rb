require 'thread'
require 'benchmark/ips'

IPS_NUM = 1_000

Benchmark.ips do |bm|
  mutex = Mutex.new
  array1 = []
  bm.report('locked') do
    IPS_NUM.times { Thread.new { mutex.synchronize { array1 << 1 } } }
  end

  bm.report('memory') do
    Thread.main[:array2] = []
    IPS_NUM.times { Thread.new { Thread.main[:array2] << 1 } }
  end

  bm.compare!
end
