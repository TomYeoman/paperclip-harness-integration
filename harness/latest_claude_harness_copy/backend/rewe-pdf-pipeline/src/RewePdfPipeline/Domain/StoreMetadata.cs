namespace RewePdfPipeline.Domain;

public sealed record StoreMetadata(
    string StoreId,
    string StoreName,
    string StoreAddress
);
