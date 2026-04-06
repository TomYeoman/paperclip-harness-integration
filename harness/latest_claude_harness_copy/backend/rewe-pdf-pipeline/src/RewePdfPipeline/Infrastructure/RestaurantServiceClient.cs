using System.Diagnostics;
using System.Net;
using System.Text.Json;
using System.Text.Json.Serialization;
using RewePdfPipeline.Domain;
using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Infrastructure;

public sealed class RestaurantServiceClient : IRestaurantServiceClient
{
    private readonly HttpClient _httpClient;

    public RestaurantServiceClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<(StoreMetadata? Metadata, int ResponseMs)> GetStoreAsync(
        string storeId,
        CancellationToken cancellationToken = default)
    {
        var sw = Stopwatch.StartNew();
        var response = await _httpClient.GetAsync($"/restaurants/{Uri.EscapeDataString(storeId)}", cancellationToken);
        sw.Stop();

        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return (null, (int)sw.ElapsedMilliseconds);
        }

        response.EnsureSuccessStatusCode();

        var json = await response.Content.ReadAsStringAsync(cancellationToken);
        var dto = JsonSerializer.Deserialize<RestaurantDto>(json, JsonOptions);

        if (dto is null)
        {
            return (null, (int)sw.ElapsedMilliseconds);
        }

        var metadata = new StoreMetadata(
            StoreId: storeId,
            StoreName: dto.Name ?? string.Empty,
            StoreAddress: dto.Address ?? string.Empty
        );

        return (metadata, (int)sw.ElapsedMilliseconds);
    }

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
    };

    private sealed class RestaurantDto
    {
        [JsonPropertyName("name")]
        public string? Name { get; set; }

        [JsonPropertyName("address")]
        public string? Address { get; set; }
    }
}
