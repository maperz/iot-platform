using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataPoller.Model
{
	class ThermometerData
	{
		public string DeviceId { get; set; } = "";
		public DateTime LastUpdate { get; set; }
		public bool Connected { get; set; }
		public double TemperatureC { get; set; }
		public double Humidity { get; set; }
		public DateTime PollTime { get; set; }
	}
}
