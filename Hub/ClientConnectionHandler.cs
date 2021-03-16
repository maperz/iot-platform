using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MQTTnet.Server;

namespace Hub
{
    public class ClientConnectionHandler : IMqttServerClientConnectedHandler, IMqttServerClientDisconnectedHandler
    {

        private readonly HashSet<Connection> _connections = new HashSet<Connection>();
        
        public Task HandleClientConnectedAsync(MqttServerClientConnectedEventArgs args)
        {
            var connection = new Connection(args.ClientId);
            if (_connections.Add(connection))
            {
                Console.WriteLine("Client connected: {0}", connection.Id);

            }
            return Task.CompletedTask;
        }

        public Task HandleClientDisconnectedAsync(MqttServerClientDisconnectedEventArgs args)
        {
            var connection = new Connection(args.ClientId);
            if (_connections.Remove(connection))
            {
                Console.WriteLine("Client disconnected: {0}", connection.Id);

            }
            return Task.CompletedTask;    
        }
    }
}