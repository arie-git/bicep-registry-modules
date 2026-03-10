using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace scenario11ui.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;

    public string? ClientPrincipalName { get; set; }

    public IndexModel(ILogger<IndexModel> logger)
    {
        _logger = logger;
    }

    public void OnGet()
    {
        if (Request.Headers.TryGetValue("X-MS-CLIENT-PRINCIPAL-NAME", out var headerValues))
        {
            ClientPrincipalName = headerValues.FirstOrDefault();
        } else {
            ClientPrincipalName = "unknown";
        }
    }
}
