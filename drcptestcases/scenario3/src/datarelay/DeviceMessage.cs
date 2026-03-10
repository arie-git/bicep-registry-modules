namespace APG.CCC
{
    public class DeviceMessage
    {
        public int Sequence { get; set; }
        public string Eui { get; set; }
        public string Payload { get; set; }
        public long Timestamp { get; set; }
    }
}
