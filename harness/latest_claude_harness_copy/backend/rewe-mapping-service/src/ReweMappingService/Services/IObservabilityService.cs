namespace ReweMappingService.Services;

public interface IObservabilityService
{
    void EmitMappingResolved(string storeId, string tcsUrl, string cloudinaryVersionId);
    void EmitLinksMissing(string storeId);
    void EmitMappingFailed(string storeId, int errorCode);
}
