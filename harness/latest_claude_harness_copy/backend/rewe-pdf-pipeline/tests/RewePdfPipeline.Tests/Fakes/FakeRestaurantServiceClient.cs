using RewePdfPipeline.Domain;
using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Tests.Fakes;

public sealed class FakeRestaurantServiceClient : IRestaurantServiceClient
{
    private readonly StoreMetadata? _metadata;
    private readonly bool _throwUnavailable;
    private readonly int _responseMs;

    public FakeRestaurantServiceClient(StoreMetadata? metadata, int responseMs = 50, bool throwUnavailable = false)
    {
        _metadata = metadata;
        _responseMs = responseMs;
        _throwUnavailable = throwUnavailable;
    }

    public Task<(StoreMetadata? Metadata, int ResponseMs)> GetStoreAsync(
        string storeId,
        CancellationToken cancellationToken = default)
    {
        if (_throwUnavailable)
        {
            throw new HttpRequestException("Restaurant Service unavailable.");
        }

        return Task.FromResult((_metadata, _responseMs));
    }
}
