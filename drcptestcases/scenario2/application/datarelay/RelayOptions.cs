namespace APG.CCC
{
    public class RelayOptions
    {
        public const string SectionName = "DataRelay";

        public string CosmosDBDatabaseName { get; set; }

        public string CosmosDBContainerName { get; set; }
    }
}
