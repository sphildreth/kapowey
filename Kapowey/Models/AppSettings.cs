namespace Kapowey.Models
{
    public class AppSettings
    {
        public string CORSOrigins {get;set;}
        public bool UseSSLBehindProxy { get; set; }
        public string BehindProxyHost { get; set; }
    }
}