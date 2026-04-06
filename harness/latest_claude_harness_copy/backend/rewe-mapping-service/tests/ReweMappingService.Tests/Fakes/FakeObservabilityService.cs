using ReweMappingService.Services;

namespace ReweMappingService.Tests.Fakes;

public class FakeObservabilityService : IObservabilityService
{
    public record MappingResolvedEvent(string StoreId, string TcsUrl, string CloudinaryVersionId);
    public record LinksMissingEvent(string StoreId);
    public record MappingFailedEvent(string StoreId, int ErrorCode);

    public List<MappingResolvedEvent> MappingResolvedEvents { get; } = new();
    public List<LinksMissingEvent> LinksMissingEvents { get; } = new();
    public List<MappingFailedEvent> MappingFailedEvents { get; } = new();

    public void EmitMappingResolved(string storeId, string tcsUrl, string cloudinaryVersionId)
        => MappingResolvedEvents.Add(new(storeId, tcsUrl, cloudinaryVersionId));

    public void EmitLinksMissing(string storeId)
        => LinksMissingEvents.Add(new(storeId));

    public void EmitMappingFailed(string storeId, int errorCode)
        => MappingFailedEvents.Add(new(storeId, errorCode));
}
