using System;
using System.Linq;
using System.Threading.Tasks;
using DataPoller.Model;
using System.Collections.Generic;
using Shared;
using System.IO;
using System.Globalization;
using System.Text.Json;
using CommandLine;
using Serilog;

namespace DataPoller
{
    public static class Program
    {
        private const string DefaultFileName = "thermo.csv";
        private const string DefaultType = "thermo";


        public class Options
        {
            [Option('o', "output", Default = DefaultFileName, HelpText = "The name of the output CSV file")]
            public string OutputFileName { get; set; } = "";

            [Option('t', "type", Default = DefaultType,
                HelpText =
                    "The sensor type to be used. Supported are thermometers (thermo) and airquality (airquality).")]
            public string SensorType { get; set; } = "";
        }

        public static async Task Main(string[] args)
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Debug()
                .WriteTo.Console(
                    outputTemplate: "[{Timestamp:dd.MM.yyyy, HH:mm:ss}][{Level:u1}] {Message:lj}{NewLine}{Exception}")
                .CreateLogger();
            try
            {
                await Parser.Default.ParseArguments<Options>(args).WithParsedAsync(options =>
                    Run(options.OutputFileName, options.SensorType)
                );
            }
            catch (Exception e)
            {
                Log.Error("Running program failed with following exception {Exception}", e.Message);
            }
        }

        private static async Task Run(string fileName, string type)
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

            if (type == "thermo")
            {
                var thermometerData = ExtractThermometerData(devices).ToList();
                await SerializeToFile(fileName, thermometerData);
            }
            else if (type == "airquality")
            {
                var qualityData = ExtractAirQuality(devices).ToList();
                await SerializeToFile(fileName, qualityData);
            }
            else
            {
                Log.Error("Unknown sensor type: {SensorType}", type);
            }
        }

        private static IEnumerable<AirQualityData> ExtractAirQuality(IEnumerable<DeviceState> devices)
        {
            var now = DateTime.UtcNow;
            var qualityDevices = devices.Where(device =>
                device.Info.Type == "airquality" && !string.IsNullOrWhiteSpace(device.State));
            return qualityDevices.Select(device =>
            {
                var state = JsonSerializer.Deserialize<AirQualityState>(device.State,
                    new JsonSerializerOptions(JsonSerializerDefaults.Web))!;
                return new AirQualityData()
                {
                    DeviceId = device.DeviceId,
                    LastUpdate = device.LastUpdate,
                    Connected = device.Connected,
                    ECo2 = state.Quality,
                    PollTime = now
                };
            });
        }

        private static IEnumerable<ThermometerData> ExtractThermometerData(IEnumerable<DeviceState> devices)
        {
            var now = DateTime.UtcNow;
            var thermometers = devices.Where(device =>
                device.Info.Type == "thermo" && !string.IsNullOrWhiteSpace(device.State));
            return thermometers.Select(thermo =>
            {
                var state = JsonSerializer.Deserialize<ThermometerState>(thermo.State,
                    new JsonSerializerOptions(JsonSerializerDefaults.Web))!;
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

        private static async Task SerializeToFile<T>(string fileName, IReadOnlyCollection<T> data)
        {
            if (!File.Exists(fileName))
            {
                Log.Information("Output file at '{FileName}' not found - Creating and writing CSV header", fileName);
                var directory = Path.GetDirectoryName(fileName);
                if (!string.IsNullOrWhiteSpace(directory))
                {
                    _ = Directory.CreateDirectory(directory);
                }

                await using var sw = File.CreateText(fileName);
                await sw.WriteLineAsync(SerializeDataToHeader<T>());
            }

            await using (var sw = File.AppendText(fileName))
            {
                Log.Information("Appending {Count} data entries to file at '{FileName}'", data.Count, fileName);
                await sw.WriteLineAsync(SerializeDataToCsv(data));
            }
        }

        private static string SerializeDataToHeader<T>()
        {
            var headers = typeof(T).GetProperties().Select(property => property.Name.ToString());
            return string.Join(',', headers);
        }

        private static string SerializeDataToCsv<T>(IEnumerable<T> entries)
        {
            CultureInfo.CurrentCulture = CultureInfo.InvariantCulture;

            var lines = entries.Select(data =>
            {
                var values = typeof(T).GetProperties()
                    .Select(property => property.GetValue(data)?.ToString() ?? "-");
                return string.Join(',', values);
            });

            return string.Join('\n', lines);
        }
    }
}