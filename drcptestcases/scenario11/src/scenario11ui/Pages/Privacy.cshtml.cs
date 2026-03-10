using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Options;

namespace scenario11ui.Pages;

public class PrivacyModel : PageModel
{
    private readonly ILogger<PrivacyModel> _logger;

    public string? ApiResponse { get; set; }

    private readonly MyApiSettings _myApiSettings;


    public PrivacyModel(ILogger<PrivacyModel> logger,
                        IOptions<MyApiSettings> myApiSettings)
    {
        _logger = logger;
        _myApiSettings = myApiSettings.Value;
    }

    public async Task OnGet()
    {
        var myApiSettingsValue = _myApiSettings.BaseUrl;
        var apiUri = $"{myApiSettingsValue}/weatherforecast"; //"https://s2c3lztst1101devsecapp002.azurewebsites.net:443/weatherforecast";
        _logger.LogInformation($"Downstream Api : {apiUri}");

        if (Request.Headers.TryGetValue("X-MS-TOKEN-AAD-ACCESS-TOKEN", out var headerValues))
        {
            var token = headerValues.FirstOrDefault() as string;
            _logger.LogInformation($"Got access token!");

            var httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
            // Call the web API.
            HttpResponseMessage response = await httpClient.GetAsync(apiUri);
            _logger.LogInformation($"Got response code {response.StatusCode}");
            ApiResponse = await response.Content.ReadAsStringAsync();
            _logger.LogInformation($"Got response {ApiResponse}");
        } else {
            _logger.LogInformation("Not logged in.");
        }
    }
}

