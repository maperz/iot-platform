namespace Hub.Config
{
    public class StorageConfig
    {
        public string DatabasePath { get; set; } = "";
        public int StateStorageIntervalSeconds { get; set; } = 600; // 10min
    }
}