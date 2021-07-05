using Test

using ZMQChannels

@testset "Releasing port when closing channels" begin
  @testset "ZMQPullChannel" begin
    @test begin
      channel = ZMQChannels.ZMQPullChannel("tcp://*:6666")
      close(channel)

      sleep(0.1)

      channel = ZMQChannels.ZMQPullChannel("tcp://*:6666")
      close(channel)
    end isa Any
  end

  @testset "ZMQPushChannel" begin
    @test begin
      channel = ZMQChannels.ZMQPushChannel("tcp://localhost:6666")
      close(channel)
      channel = ZMQChannels.ZMQPushChannel("tcp://localhost:6666")
      close(channel)
    end isa Any
  end
end

@testset "Can open channels again after closing" begin
  @testset "ZMQPullChannel" begin
    @test begin
      channel = ZMQChannels.ZMQPullChannel("tcp://*:6666")
      close(channel)
      
      sleep(0.1)

      ZMQChannels.open(channel)
      close(channel)
    end isa Any
  end

  @testset "ZMQPushChannel" begin
    @test begin
      channel = ZMQChannels.ZMQPushChannel("tcp://localhost:6666")
      close(channel)
      
      sleep(0.1)

      ZMQChannels.open(channel)
      close(channel)
    end isa Any
  end
end

@testset "take() throws InvalidStateException on close()" begin
  @testset "Closing first" begin
    channel = ZMQChannels.ZMQPullChannel("tcp://*:6666")
    close(channel)
    @test_throws InvalidStateException take!(channel)
  end

  @testset "Closing last" begin
    channel = ZMQChannels.ZMQPullChannel("tcp://*:6666")
    c = Condition()
    t = @async begin
      @assert isopen(channel)
      notify(c)
      take!(channel)
    end
    wait(c)
    close(channel)
    try
      wait(t)
    catch e
      @static if VERSION >= v"1.3"
        if isa(e, TaskFailedException) # Unwrap TaskFailedExpcetion
          e = e.task.exception
        end
      end
      @test isa(e, InvalidStateException)
    end
  end  
end
