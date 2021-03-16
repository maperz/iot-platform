using System;

namespace Hub
{
    public class Connection : IEquatable<Connection>
    {
        public string Id { get; }

        public Connection(string id)
        {
            this.Id = id;
        }

        public bool Equals(Connection? other)
        {
            return other != null && this.Id.Equals(other.Id);
        }

        public override int GetHashCode()
        {
            return Id.GetHashCode();
        }
    }
}