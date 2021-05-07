using System;
#nullable disable

namespace Shared
{
    public class Device : IEquatable<Device>
    {
        public string Id { get; }
        
        public string Name { get; set; }

        public Device(string id)
        {
            Id = id;
        }
        
#nullable enable
        public bool Equals(Device? other)
        {
            return other != null && Id.Equals(other.Id);
        }

        public override int GetHashCode()
        {
            return Id.GetHashCode();
        }
    }
}