using LoggerLinux.Configuration;
using System.Net.NetworkInformation;

namespace LostArkLogger
{
    public class Program
    {
        public static void Main(string[] args)
        {
            // Shutdown hook
            AppDomain.CurrentDomain.ProcessExit += (sender, eventArgs) => { LostArkLogger.Instance.Server?.Stop(); };
            LostArkLogger.Instance.onLaunch(args);

            while (true)
            {
                Console.ReadLine();
            }
        }
    }

    public class LostArkLogger
    {
        private static LostArkLogger? _instance = null;

        public static LostArkLogger Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new LostArkLogger();
                }

                return _instance;
            }
        }

        public ConfigurationProvider ConfigurationProvider;
        public HttpBridge? Server;

        public void onLaunch(string[] args)
        {
            this.ConfigurationProvider = new ConfigurationProvider();
            this.Server = new HttpBridge() { args = args };

            this.Server.Start();
        }
    }
}