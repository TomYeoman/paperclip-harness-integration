using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Tests.Fakes;

public sealed class FakeMappingRegistrar : IMappingRegistrar
{
    public string? LastRegisteredStoreId { get; private set; }
    public string? LastRegisteredPdfUrl { get; private set; }

    public Task RegisterPdfUrlAsync(
        string storeId,
        string pdfUrl,
        CancellationToken cancellationToken = default)
    {
        LastRegisteredStoreId = storeId;
        LastRegisteredPdfUrl = pdfUrl;
        return Task.CompletedTask;
    }
}
