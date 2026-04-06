using System.Text.Json;
using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Infrastructure;

public sealed class JsonObservabilityLogger : IObservabilityLogger
{
    private static readonly JsonSerializerOptions Options = new()
    {
        WriteIndented = false,
    };

    public void LogTcsGeneratedAndCached(
        string storeId,
        string storeName,
        string storeAddress,
        long pdfSizeBytes,
        string pdfUrl,
        int restaurantServiceResponseMs)
    {
        var payload = new
        {
            @event = "pdf.tcs_generated_and_cached",
            store_id = storeId,
            store_name = storeName,
            store_address = storeAddress,
            pdf_size_bytes = pdfSizeBytes,
            pdf_url = pdfUrl,
            restaurant_service_response_ms = restaurantServiceResponseMs,
        };

        Console.WriteLine(JsonSerializer.Serialize(payload, Options));
    }
}
