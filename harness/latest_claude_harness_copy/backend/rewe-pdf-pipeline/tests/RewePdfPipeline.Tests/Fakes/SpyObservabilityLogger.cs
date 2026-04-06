using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Tests.Fakes;

public sealed class SpyObservabilityLogger : IObservabilityLogger
{
    public string? StoreId { get; private set; }
    public string? StoreName { get; private set; }
    public string? StoreAddress { get; private set; }
    public long? PdfSizeBytes { get; private set; }
    public string? PdfUrl { get; private set; }
    public int? RestaurantServiceResponseMs { get; private set; }
    public bool WasCalled { get; private set; }

    public void LogTcsGeneratedAndCached(
        string storeId,
        string storeName,
        string storeAddress,
        long pdfSizeBytes,
        string pdfUrl,
        int restaurantServiceResponseMs)
    {
        WasCalled = true;
        StoreId = storeId;
        StoreName = storeName;
        StoreAddress = storeAddress;
        PdfSizeBytes = pdfSizeBytes;
        PdfUrl = pdfUrl;
        RestaurantServiceResponseMs = restaurantServiceResponseMs;
    }
}
