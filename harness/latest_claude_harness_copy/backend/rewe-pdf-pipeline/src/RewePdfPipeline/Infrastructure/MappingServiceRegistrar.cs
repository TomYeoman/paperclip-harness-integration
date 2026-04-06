using System.Text;
using System.Text.Json;
using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Infrastructure;

public sealed class MappingServiceRegistrar : IMappingRegistrar
{
    private readonly HttpClient _httpClient;

    public MappingServiceRegistrar(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task RegisterPdfUrlAsync(
        string storeId,
        string pdfUrl,
        CancellationToken cancellationToken = default)
    {
        var payload = JsonSerializer.Serialize(new { pdf_url = pdfUrl });
        var content = new StringContent(payload, Encoding.UTF8, "application/json");

        var response = await _httpClient.PutAsync(
            $"/store-docs/{Uri.EscapeDataString(storeId)}",
            content,
            cancellationToken);

        response.EnsureSuccessStatusCode();
    }
}
