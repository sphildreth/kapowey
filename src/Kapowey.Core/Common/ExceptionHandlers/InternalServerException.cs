namespace Kapowey.Core.Common.ExceptionHandlers;
public class InternalServerException : ServerException
{
    public InternalServerException(string message)
        : base(message, System.Net.HttpStatusCode.InternalServerError)
    {
    }
}