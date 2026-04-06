namespace RewePdfPipeline.Interfaces;

public interface IObservabilityLogger
{
    void LogTcsGeneratedAndCached(
        string storeId,
        string storeName,
        string storeAddress,
        long pdfSizeBytes,
        string pdfUrl,
        int restaurantServiceResponseMs
    );
}
