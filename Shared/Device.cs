using System;

namespace Shared
{
    public class Device : IEquatable<Device>
    {
        public string Id { get; }

        public Device(string id)
        {
            this.Id = id;
        }

        public bool Equals(Device? other)
        {
            return other != null && this.Id.Equals(other.Id);
        }

        public override int GetHashCode()
        {
            return Id.GetHashCode();
        }
    }
}