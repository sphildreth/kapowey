using Microsoft.Extensions.Logging;
using System;

namespace Kapowey.Extensions
{
    public static class LoggerExtensions
    {
        public static void LogError(this ILogger logger, Exception ex)
        {
            logger.LogError(default, ex, null, null);
        }
    }
}