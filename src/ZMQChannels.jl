module ZMQChannels

using ZMQ
import Base: put!, take!, isready, fetch, isopen, close, bind, finalize, iterate
export put!, take!, isready, fetch, isopen, close, bind, iterate

function put!(socket::Socket, value)
    send(socket, value)
end

function take!(socket::Socket)
    return recv(socket)
end

function isready(socket::Socket)
    return true
end


export ZMQPullChannel, ZMQPushChannel

mutable struct ZMQChannel
    socket::Socket
    function ZMQChannel(socket::Socket)
        this = new()
        this.socket = socket
        return this
    end
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


function put!(channel::ZMQChannel, input)
    send(channel.socket, input)
end


function take!(channel::ZMQChannel)
    recv(channel.socket)
end

function iterate(channel::ZMQChannel, state::Any=nothing)
    if (isopen(channel))
        return (take!(channel), nothing)
    end
    return nothing
end

function isready(channel::ZMQChannel)
    isready(channel.socket)
end

function fetch(channel::ZMQChannel)
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
