using System;
using System.ComponentModel.DataAnnotations;

namespace Kapowey.Models
{
    [Serializable]
    public sealed class AuthenticateRequest
    {
        [Required]
        public string Username { get; set; }

        [Required]
        public string Password { get; set; }
    }
}