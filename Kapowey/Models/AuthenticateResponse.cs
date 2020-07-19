using Kapowey.Models.API.Entities;

namespace Kapowey.Models
{
    public class AuthenticateResponse
    {
        public UserInfo User { get;  }
        public string Token { get; }

        public AuthenticateResponse(UserInfo user, string token)
        {
            User = user;
            Token = token;
        }
    }
}