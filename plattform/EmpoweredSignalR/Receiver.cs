using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR.Client;
using Newtonsoft.Json;
using JsonSerializer = System.Text.Json.JsonSerializer;

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
                Task resultTask;
                
                if (parameterInfos.Length == 0)
                {
                    object[] parameters = new object[] {  };
                    resultTask = (Task) methodInfo.Invoke(this, parameters)!;
                }
                else if (parameterInfos.Length == 1)
                {
                    object[] parameters = new object[] { JsonConvert.DeserializeObject(request.Payload, parameterInfos[0].GetType()) };
                    resultTask = (Task) methodInfo.Invoke(this, parameters)!;
                }
                else
                {
                    return;
                }
                
                await resultTask.ConfigureAwait(false);
                var resultObject = resultTask.GetType().GetProperty("Result")?.GetValue(resultTask);

                object result = resultObject ?? new EmptyObject();
                
                var payload = JsonSerializer.Serialize(result);
                
                await connection.SendAsync(nameof(EmpoweredHub.OnBidirectionalReply),
                    new BidirectionalMessage()
                    {
                        Id = request.Id, Payload = payload
                    });     
             
            }
            catch (Exception)
            {
                // ignored
            }
        }
    }
}