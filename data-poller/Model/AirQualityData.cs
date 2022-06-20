using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataPoller.Model
{
	class AirQualityData
	{
		public string DeviceId { get; set; } = "";
		public DateTime LastUpdate { get; set; }
		public bool Connected { get; set; }
		public double ECo2 { get; set; }
		
		public double Organic { get; set; }
		
		public double Temp { get; set; }
		
		public double Hum { get; set; }

		public DateTime PollTime { get; set; }
	}
}
