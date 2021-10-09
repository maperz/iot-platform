using System.Threading.Tasks;

namespace EmpoweredSignalR.Tests.Client
{
    public class MockReceiver : Receiver
    {
        private int _pingCounter = 0;
        
        public int GetPingCounter()
        {
            return _pingCounter;
        }
        
        public Task<EmptyObject> Ping()
        {
            _pingCounter++;
            return Task.FromResult(new EmptyObject());
        }

        public static Task<TextMessage> ToUpper(TextMessage request)
        {
            var response = new TextMessage()
            {
                Text = request.Text.ToUpper()
            };
            
            return Task.FromResult(response);
        }
    }
}