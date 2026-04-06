using RewePdfPipeline.Domain;

namespace RewePdfPipeline.Interfaces;

public interface IRestaurantServiceClient
{
    /// <summary>
    /// Fetches store metadata from the Restaurant Service.
    /// Returns null if the store is not found.
    /// Throws <see cref="HttpRequestException"/> if the service is unavailable.
    /// </summary>
    Task<(StoreMetadata? Metadata, int ResponseMs)> GetStoreAsync(string storeId, CancellationToken cancellationToken = default);
}
