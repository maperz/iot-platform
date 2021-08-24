using System;
using System.Linq;
using System.Threading.Tasks;
using DataPoller.Model;
using System.Collections.Generic;
using Shared;
using System.IO;
using System.Globalization;
using System.Text.Json;
using Serilog;

namespace DataPoller
{
    public static class Program
    {
        private const string DefaultFileName = "thermo.csv";

        public static async Task Main(string[] args)
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Debug()
                .WriteTo.Console(outputTemplate: "[{Timestamp:dd.MM.yyyy, HH:mm:ss}][{Level:u1}] {Message:lj}{NewLine}{Exception}")
                .CreateLogger();
            
            var filename = args.FirstOrDefault() ?? DefaultFileName;
            
            try
            {
                await Run(filename);
            }
            catch (Exception e)
			{
                Log.Error("Running program failed with following exception {Exception}", e.Message);
            }
        }

        private static async Task Run(string fileName)
		{
            var serviceDiscovery = new HubServiceDiscovery();

            var hubAddress = await serviceDiscovery.GetHubAddress();

            if (hubAddress == null)
            {
                Log.Error("Failed to retrieve Hub address - Quitting");
                return;
            }
            
            var client = new IoTApiClient(hubAddress);

            var devices = await client.GetDevices();

            var thermoData = ExtractThermometerData(devices).ToList();

            if (!File.Exists(fileName))
            {
                Log.Information("Output file at '{FileName}' not found - Creating and writing CSV header", fileName);
                var directory = Path.GetDirectoryName(fileName);
                if (!string.IsNullOrWhiteSpace(directory))
                {
                    _ = Directory.CreateDirectory(directory!);
                }
                
                await using StreamWriter sw = File.CreateText(fileName);
                await sw.WriteLineAsync(SerializeDataToHeader());
            }

            await using (StreamWriter sw = File.AppendText(fileName))
            {
                Log.Information("Appending {Count} data entries to file at '{FileName}'", thermoData.Count, fileName);
                await sw.WriteLineAsync(SerializeDataToCsv(thermoData));
            }
        }

        private static IEnumerable<ThermometerData> ExtractThermometerData(IEnumerable<DeviceState> devices)
		{
            var now = DateTime.UtcNow;
            var thermometers = devices.Where(device => device.Info.Type == "thermo" && !string.IsNullOrWhiteSpace(device.State));
            return thermometers.Select(thermo =>
            {
                var state = JsonSerializer.Deserialize<ThermometerState>(thermo.State, new JsonSerializerOptions(JsonSerializerDefaults.Web))!;
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

        private static string SerializeDataToHeader()
		{
            var headers = typeof(ThermometerData).GetProperties().Select(property => property.Name.ToString());
            return string.Join(',', headers);
        }

        private static string SerializeDataToCsv(IEnumerable<ThermometerData> thermometers) 
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
 