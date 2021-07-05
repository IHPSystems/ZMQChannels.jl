module ZMQChannels

using ZMQ

import Base: put!, take!, isready, fetch, isopen, close, bind, finalize, iterate

export put!, take!, isready, fetch, isopen, open, close, bind, iterate

export ZMQPullChannel, ZMQPushChannel

abstract type ZMQChannel <: AbstractChannel{Vector{UInt8}} end

mutable struct ZMQPullChannel <: ZMQChannel
    context::Context
    url::String
    socket::Socket

    function ZMQPullChannel(context::Context, url::String)
        channel = new(context, url, Socket(context, PULL))
        bind(channel.socket, url)
        return channel
    end
end

function ZMQPullChannel(url::String)
    return ZMQPullChannel(ZMQ.context(), url)
end

mutable struct ZMQPushChannel <: ZMQChannel
    context::Context
    url::String
    socket::Socket

    function ZMQPushChannel(context::Context, url::String)
        channel = new(context, url, Socket(context, PUSH))
        connect(channel.socket, url)
        return channel
    end
end

function ZMQPushChannel(url::String)
    return ZMQPushChannel(ZMQ.context(), url)
end

function put!(channel::ZMQChannel, value::Vector{UInt8})
    send(channel.socket, value)
end

function take!(channel::ZMQChannel)::Vector{UInt8}
    try
        recv(channel.socket)
    catch e
        if isa(e, ZMQ.StateError)
            throw(InvalidStateException("Channel is closed.", :closed))
        elseif isa(e, EOFError)
            throw(InvalidStateException("Channel is closed.", :closed))
        else
            rethrow(e)
        end
    end
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

function open(channel::ZMQPullChannel)
    if !isopen(channel)
        channel.socket = Socket(channel.context, PULL)
        bind(channel.socket, channel.url)
    end
end

function open(channel::ZMQPushChannel)
    if !isopen(channel)
        channel.socket = Socket(channel.context, PUSH)
        connect(channel.socket, channel.url)
    end
end

function bind(channel::ZMQChannel, task::Task)
    bind(channel.socket, task)
end

function finalize(channel::ZMQChannel)
    close(channel)
end

end # module
