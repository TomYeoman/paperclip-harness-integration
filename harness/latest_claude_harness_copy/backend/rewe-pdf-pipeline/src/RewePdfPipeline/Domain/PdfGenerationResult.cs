namespace RewePdfPipeline.Domain;

public sealed record PdfGenerationResult(
    string StoreId,
    string PdfUrl,
    long PdfSizeBytes,
    int RestaurantServiceResponseMs
);
