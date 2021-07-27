
using System;
using System.Net.Http;
using System.Linq;
using System.Threading.Tasks;
using DataPoller.Model;
using System.Collections.Generic;
using Shared;
using Newtonsoft.Json;
using System.IO;
using System.Globalization;

namespace DataPoller
{
    public class Program
    {
        public static readonly string DefaultFileName = "thermo.csv";

        public static async Task Main(string[] args)
        {
            var filename = args.FirstOrDefault() ?? DefaultFileName;
            var program = new Program();
            try
            {
                await program.Run(filename);
            }
            catch (Exception e)
			{
                Console.WriteLine($"Running program failed with following exception:\n{e.Message}");
            }
        }

        private async Task Run(string filename)
		{
            var serviceDiscovery = new HubServiceDiscovery();

            var hubAddress = await serviceDiscovery.GetHubAddress();

            if (hubAddress == null)
            {
                Console.WriteLine("Failed to retrieve Hub address - Quitting");
                return;
            }
            
    
            var client = new IoTApiClient(hubAddress);

            var devices = await client.GetDevices();

            var thermoData = ExtractThermometerData(devices);

            if (!File.Exists(filename))
            {
				_ = Directory.CreateDirectory(Path.GetDirectoryName(filename)!);
                Console.WriteLine($"Output file at '{filename}' not found - Creating and writing CSV header");
                using (StreamWriter sw = File.CreateText(filename))
                {
                    sw.WriteLine(SerializeDataToHeader());
                }
            }

            using (StreamWriter sw = File.AppendText(filename))
            {
                Console.WriteLine($"Appending {thermoData.Count()} data entries to file at '{filename}'");
                sw.WriteLine(SerializeDataToCSV(thermoData));
            }
        }

        private IEnumerable<ThermometerData> ExtractThermometerData(IEnumerable<DeviceState> devices)
		{
            var now = DateTime.UtcNow;
            var thermometers = devices.Where(device => device.Info.Type == "thermo" && !string.IsNullOrWhiteSpace(device.State));
            return thermometers.Select(thermo =>
            {
                var state = JsonConvert.DeserializeObject<ThermometerState>(thermo.State);
                return new ThermometerData()
                {
                    DeviceId = thermo.DeviceId,
                    LastUpdate = thermo.LastUpdate,
                    Connected = thermo.Connected,
                    TemperatureC = state.Temp,
                    Humidity = state.Hum,
                    PollTime = now
                };
            });
        }

        private string SerializeDataToHeader()
		{
            var headers = typeof(ThermometerData).GetProperties().Select(property => property.Name.ToString());
            return string.Join(',', headers);
        }

        private string SerializeDataToCSV(IEnumerable<ThermometerData> thermometers) 
		{
            CultureInfo.CurrentCulture = CultureInfo.InvariantCulture;

            var lines = thermometers.Select(data =>
            {
                var values = typeof(ThermometerData).GetProperties().Select(property => property.GetValue(data)?.ToString() ?? "-");
                return string.Join(',', values);
            });

            return string.Join('\n', lines);
        }
    }
}
 