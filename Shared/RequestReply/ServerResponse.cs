namespace Shared.RequestReply
{
    #nullable disable
    public class ServerResponse<T>
    {
        public string RequestId { get; set; }
        
        public T Response { get; set; }
    }
    #nullable enable
}