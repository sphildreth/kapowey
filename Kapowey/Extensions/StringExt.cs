namespace Kapowey.Extensions
{
    public static class StringExt
    {
        /// <summary>
        /// For the given key add the id and return formatted key to user for Caching
        /// </summary>
        /// <param name="key">Key template</param>
        /// <param name="id">Id for operation</param>
        /// <returns>Formatted key</returns>
        public static string ToCacheKey(this string key, object id) => string.Format(key, id);
    }
}