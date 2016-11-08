require 'concurrent'
require 'celluloid/current'

module ConcurrentModules
  class CelluloidClass
    include Celluloid
    def foo(latch = nil)
      latch.count_down if latch
    end
  end
  
  class AsyncClass
    include Concurrent::Async
    def foo(latch = nil)
      latch.count_down if latch
    end
  end

  def self.perform(t, mod)
    latch = Concurrent::CountDownLatch.new(t)
    t.times { mod.async.foo(latch) }
    latch.wait
  end
end

