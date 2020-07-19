namespace Kapowey.Services.Models
{
    public interface IHttpContext
    {
        string BaseUrl { get; set; }
        string ImageBaseUrl { get; set; }
    }
}