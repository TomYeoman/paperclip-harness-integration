using RewePdfPipeline.Domain;
using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Pipeline;

public sealed class PdfGenerationPipeline
{
    private readonly IRestaurantServiceClient _restaurantClient;
    private readonly IPdfGenerator _pdfGenerator;
    private readonly ICloudinaryClient _cloudinaryClient;
    private readonly IMappingRegistrar _mappingRegistrar;
    private readonly IObservabilityLogger _observabilityLogger;

    public PdfGenerationPipeline(
        IRestaurantServiceClient restaurantClient,
        IPdfGenerator pdfGenerator,
        ICloudinaryClient cloudinaryClient,
        IMappingRegistrar mappingRegistrar,
        IObservabilityLogger observabilityLogger)
    {
        _restaurantClient = restaurantClient;
        _pdfGenerator = pdfGenerator;
        _cloudinaryClient = cloudinaryClient;
        _mappingRegistrar = mappingRegistrar;
        _observabilityLogger = observabilityLogger;
    }

    /// <summary>
    /// Runs the full PDF generation pipeline for a store.
    /// Throws <see cref="InvalidOperationException"/> if store_name or store_address is empty.
    /// Throws <see cref="HttpRequestException"/> if Restaurant Service is unavailable (caller must retry).
    /// </summary>
    public async Task<PdfGenerationResult> RunAsync(string storeId, CancellationToken cancellationToken = default)
    {
        var (metadata, responseMs) = await _restaurantClient.GetStoreAsync(storeId, cancellationToken);

        if (metadata is null)
        {
            throw new InvalidOperationException($"Restaurant Service returned no data for store {storeId}.");
        }

        if (string.IsNullOrWhiteSpace(metadata.StoreName))
        {
            throw new InvalidOperationException(
                $"Restaurant Service returned empty store_name for store {storeId}. PDF generation aborted.");
        }

        if (string.IsNullOrWhiteSpace(metadata.StoreAddress))
        {
            throw new InvalidOperationException(
                $"Restaurant Service returned empty store_address for store {storeId}. PDF generation aborted.");
        }

        var pdfBytes = _pdfGenerator.GenerateTcsPdf(metadata);
        var pdfUrl = await _cloudinaryClient.UploadPdfAsync(storeId, pdfBytes, cancellationToken);
        await _mappingRegistrar.RegisterPdfUrlAsync(storeId, pdfUrl, cancellationToken);

        _observabilityLogger.LogTcsGeneratedAndCached(
            storeId: metadata.StoreId,
            storeName: metadata.StoreName,
            storeAddress: metadata.StoreAddress,
            pdfSizeBytes: pdfBytes.Length,
            pdfUrl: pdfUrl,
            restaurantServiceResponseMs: responseMs
        );

        return new PdfGenerationResult(
            StoreId: storeId,
            PdfUrl: pdfUrl,
            PdfSizeBytes: pdfBytes.Length,
            RestaurantServiceResponseMs: responseMs
        );
    }
}
