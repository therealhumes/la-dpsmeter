using System;
using System.Collections.Generic;
namespace LostArkLogger
{
    public partial class PKTStatusEffectRemoveNotify
    {
        public PKTStatusEffectRemoveNotify(BitReader reader)
        {
            if (LostArkLogger.Instance.ConfigurationProvider.Configuration.Region == Region.Steam) SteamDecode(reader);
            if (LostArkLogger.Instance.ConfigurationProvider.Configuration.Region == Region.Korea) KoreaDecode(reader);
        }
        public List<UInt32> InstanceIds;
        public UInt64 ObjectId;
        public Byte Reason;
    }
}
