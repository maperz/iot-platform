using System.Collections.Generic;

namespace Server.Data.Entities
{
    public class Hub
    {
        public string Id { get; set; } = null!;

        public virtual IEnumerable<ApplicationUser> Users { get; set; } = null!;
    }
}