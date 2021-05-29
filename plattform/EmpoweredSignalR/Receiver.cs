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
                    throw new Exception("Method does not exist");
                }
                
                var parameterInfos = methodInfo.GetParameters();
                Task resultTask;
                switch (parameterInfos.Length)
                {
                    case 0:
                        resultTask = (Task) methodInfo.Invoke(this, Array.Empty<object>())!;
                        break;
                    case 1:
                    {
                        object[] parameters = new[] { JsonConvert.DeserializeObject(request.Payload, parameterInfos[0].GetType()) };
                        resultTask = (Task) methodInfo.Invoke(this, parameters)!;
                        break;
                    }
                    default:
                        throw new Exception("Only method with 0 or 1 arguments supported");
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
            catch (Exception exception)
            {
                await connection.SendAsync(nameof(EmpoweredHub.OnBidirectionalReply),
                    new BidirectionalMessage()
                    {
                        Id = request.Id, Exception = exception
                    });
            }
        }
    }
}