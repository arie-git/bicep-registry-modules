using Microsoft.Extensions.Configuration;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(APG.CCC.Startup))]

namespace APG.CCC
{
    public class Startup: FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            _ = builder.Services.AddOptions<RelayOptions>().Configure<IConfiguration>((settings, configuration) =>
            {
                configuration.GetSection(RelayOptions.SectionName).Bind(settings);
            });
        }
    }
}

