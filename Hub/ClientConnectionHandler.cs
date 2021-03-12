using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Hub;
using MQTTnet.Server;

namespace Hub
{
    public class ClientConnectionHandler : IMqttServerClientConnectedHandler, IMqttServerClientDisconnectedHandler
    {

        private readonly HashSet<Connection> _connections = new HashSet<Connection>();
        
        public Task HandleClientConnectedAsync(MqttServerClientConnectedEventArgs args)
        {
            var connection = new Connection(args.ClientId);
            Console.WriteLine("Client connected: {0}", connection.Id);
            _connections.Add(connection);
            return Task.CompletedTask;
        }

        public Task HandleClientDisconnectedAsync(MqttServerClientDisconnectedEventArgs args)
        {
            var connection = new Connection(args.ClientId);
            Console.WriteLine("Client disconnected: {0}", connection.Id);
            _connections.Remove(connection);
            return Task.CompletedTask;    
        }
    }
}