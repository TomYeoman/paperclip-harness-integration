using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Tests.Fakes;

public sealed class FakeCloudinaryClient : ICloudinaryClient
{
    private readonly string _baseUrl;

    public string? LastUploadedStoreId { get; private set; }
    public byte[]? LastUploadedBytes { get; private set; }

    public FakeCloudinaryClient(string baseUrl = "https://res.cloudinary.com/test/raw/upload")
    {
        _baseUrl = baseUrl;
    }

    public Task<string> UploadPdfAsync(
        string storeId,
        byte[] pdfBytes,
        CancellationToken cancellationToken = default)
    {
        LastUploadedStoreId = storeId;
        LastUploadedBytes = pdfBytes;
        var url = $"{_baseUrl}/v1/rewe/tcs/{storeId}/tc_v1.pdf";
        return Task.FromResult(url);
    }
}
