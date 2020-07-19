namespace Kapowey.Models.API.Entities
{

    /// <summary>
    /// User detail record
    /// </summary>
    public sealed class User : UserInfo
    {
        public string[] Tags { get; set; }
    }
}