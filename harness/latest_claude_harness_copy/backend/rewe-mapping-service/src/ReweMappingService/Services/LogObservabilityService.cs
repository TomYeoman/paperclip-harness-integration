namespace ReweMappingService.Services;

public class LogObservabilityService : IObservabilityService
{
    private readonly ILogger<LogObservabilityService> _logger;

    public LogObservabilityService(ILogger<LogObservabilityService> logger)
    {
        _logger = logger;
    }

    public void EmitMappingResolved(string storeId, string tcsUrl, string cloudinaryVersionId)
    {
        _logger.LogInformation(
            "event=checkout.tcs_mapping_resolved store_id={StoreId} tcs_url={TcsUrl} cloudinary_version_id={CloudinaryVersionId} source=mapping_service",
            storeId, tcsUrl, cloudinaryVersionId);
    }

    public void EmitLinksMissing(string storeId)
    {
        _logger.LogInformation(
            "event=checkout.tcs_links_missing store_id={StoreId}",
            storeId);
    }

    public void EmitMappingFailed(string storeId, int errorCode)
    {
        _logger.LogWarning(
            "event=checkout.tcs_mapping_failed store_id={StoreId} error_code={ErrorCode}",
            storeId, errorCode);
    }
}
