namespace Kapowey.Caching
{
    public interface ICacheSerializer
    {
        string Serialize(object o);

        TOut Deserialize<TOut>(string s);
    }
}