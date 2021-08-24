using System;
using System.Threading;
using System.Threading.Tasks;
using EmpoweredSignalR.Tests.Client;
using EmpoweredSignalR.Tests.Hub;
using Xunit;

namespace EmpoweredSignalR.Tests
{
    public class EmpoweredHubTests
    {
        [Fact]
        private async Task TestNoParameterCall()
        {
            HubDriver<ExampleHub> driver = new();
            driver.Start();
            using (driver)
            {
                MockReceiver receiver = new();
                ExampleClient client = new(receiver);
                await client.Start();
                await using (client)
                {
                    Assert.Equal(0, receiver.GetPingCounter());
                    await client.MakePingRequest();
                    await client.MakePingRequest();
                    await client.MakePingRequest();
                    Assert.Equal(3, receiver.GetPingCounter());
                }
            }
        }

        [Fact]
        private async Task TestSingleParameterCall()
        {
            HubDriver<ExampleHub> driver = new();
            driver.Start();
            using (driver)
            {
                MockReceiver receiver = new();
                ExampleClient client = new(receiver);

                await client.Start();
                await using (client)
                {
                    var response = await client.MakeToUpperRequest("example_text");
                    Assert.Equal("EXAMPLE_TEXT", response);
                }
            }
        }
    }
}