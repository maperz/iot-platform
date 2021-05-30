using System.Collections.Generic;
using Microsoft.AspNetCore.Identity;

namespace Server.Data.Entities
{
    public class ApplicationUser : IdentityUser
    {
        public Hub? Hub { get; set; }
    }
}