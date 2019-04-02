using Test

import ZMQ
import ZMQChannels

@testset "Releasing port when closing channels" begin
  @testset "ZMQPullChannel" begin
      try
        channel = ZMQChannels.ZMQPullChannel("tcp://*:6666")
        close(channel)

        sleep(0.1)

        channel = ZMQChannels.ZMQPullChannel("tcp://*:6666")
        close(channel)
      catch e
        @error "Should now throw any exceptions. Got: $e"
        @test false
      end
  end

  @testset "ZMQPushChannel" begin
    try
      channel = ZMQChannels.ZMQPushChannel("tcp://localhost:6666")
      close(channel)
      channel = ZMQChannels.ZMQPushChannel("tcp://localhost:6666")
      close(channel)
    catch e
      @error "Should now throw any exceptions. Got: $e"
      @test false
    end
  end
end
