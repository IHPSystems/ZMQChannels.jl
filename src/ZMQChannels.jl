module ZMQChannels

using ZMQ

import Base: put!, take!, isready, fetch, isopen, close, bind, finalize, iterate

export put!, take!, isready, fetch, isopen, close, bind, iterate

export ZMQPullChannel, ZMQPushChannel

mutable struct ZMQChannel <: AbstractChannel{Vector{UInt8}}
    socket::Socket
end

function ZMQPullChannel(context::Context, url::String)
    channel = ZMQChannel(Socket(context, PULL))
    bind(channel.socket, url)
    return channel
end

function ZMQPullChannel(url::String)
    return ZMQPullChannel(ZMQ.context(), url)
end

function ZMQPushChannel(context::Context, url::String)
    channel = ZMQChannel(Socket(context, PUSH))
    connect(channel.socket, url)
    return channel
end

function ZMQPushChannel(url::String)
    return ZMQPushChannel(ZMQ.context(), url)
end

function put!(channel::ZMQChannel, value::Vector{UInt8})
    send(channel.socket, value)
end

function take!(channel::ZMQChannel)::Vector{UInt8}
    recv(channel.socket)
end

function iterate(channel::ZMQChannel, state::Any=nothing)
    if (isopen(channel))
        return (take!(channel), nothing)
    end
    return nothing
end

function isready(channel::ZMQChannel)
    return true
end

function fetch(channel::ZMQChannel)::Vector{UInt8}
    fetch(channel.socket)
end

function close(channel::ZMQChannel)
    close(channel.socket)
end

function isopen(channel::ZMQChannel)
    isopen(channel.socket)
end

function bind(channel::ZMQChannel, task::Task)
    bind(channel.socket, task)
end

function finalize(channel::ZMQChannel)
    close(channel)
end

end # module
