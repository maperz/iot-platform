using DataPoller.Model;
using Shared;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

namespace DataPoller
{
	class IoTApiClient
	{
		private readonly HttpClient _client = new();
		private readonly string _baseAddress;

		public IoTApiClient(string host)
		{
			_baseAddress = $"http://{host}/api";
		}

		public async Task<IEnumerable<DeviceState>> GetDevices(IEnumerable<string>? devices = null)
		{
			var endpoint = $"{_baseAddress}/devices";

			if (devices != null)
			{
				endpoint += "?" + string.Join("&", devices.Select(id => "devices=" + id));
			}

			var response = await _client.GetAsync(endpoint);
			var json = await response.Content.ReadAsStringAsync();
			
			var deviceStates = JsonSerializer.Deserialize<IEnumerable<DeviceState>>(json, new JsonSerializerOptions(JsonSerializerDefaults.Web));
			return deviceStates ?? Array.Empty<DeviceState>();
		}

		public async Task SendDeviceRequest(string deviceId, string name, string value)
		{
			var address = $"{_baseAddress}/devices";
			var request = new DeviceStateRequest() { DeviceId = deviceId, Name = name, Payload = value };
			
			var content = new StringContent(JsonSerializer.Serialize(request, new JsonSerializerOptions(JsonSerializerDefaults.Web)));
			await _client.PostAsync(address, content);
		}
	}
}
