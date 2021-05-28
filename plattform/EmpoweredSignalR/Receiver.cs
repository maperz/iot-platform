using System;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR.Client;

namespace EmpoweredSignalR
{
    public class Receiver
    {
        public async Task OnBidirectionalRequest(HubConnection connection, BidirectionalMessage request)
        {
            try
            {
                var methodInfo = GetType().GetMethod(request.Endpoint);
                if (methodInfo == null)
                {
                    // TODO
                    // No method found that is called this way - should handle errors somehow later
                    return;
                }
                
                var parameterInfos = methodInfo.GetParameters();
                Task<object>? resultObject = null;
                
                if (parameterInfos.Length == 0)
                {
                    object[] parameters = new object[] {  };
                    resultObject = methodInfo.Invoke(this, parameters) as Task<object>;
                }
                else if (parameterInfos.Length == 1)
                {
                    object[] parameters = new object[] {  };
                    resultObject = methodInfo.Invoke(this, parameters) as Task<object>;;
                }
                
                if (resultObject != null)
                {
                    var result = await resultObject;
                    var type = result.GetType();
                    var payload = JsonSerializer.Serialize(result);
                    
                    await connection.SendAsync(nameof(EmpoweredHub.OnBidirectionalReply),
                        new BidirectionalMessage()
                        {
                            Id = request.Id, Payload = payload, PayloadType = type.Name
                        });
                }
            }
            catch (Exception)
            {
                // ignored
            }
        }
    }
}