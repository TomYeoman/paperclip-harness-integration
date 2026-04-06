using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Infrastructure;

public sealed class CloudinaryPdfClient : ICloudinaryClient
{
    private readonly Cloudinary _cloudinary;

    public CloudinaryPdfClient(Cloudinary cloudinary)
    {
        _cloudinary = cloudinary;
    }

    public async Task<string> UploadPdfAsync(
        string storeId,
        byte[] pdfBytes,
        CancellationToken cancellationToken = default)
    {
        var version = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var publicId = $"rewe/tcs/{storeId}/tc_v{version}";
        var fileName = $"{storeId}_tcs_v{version}.pdf";

        using var stream = new MemoryStream(pdfBytes);
        var uploadParams = new RawUploadParams
        {
            File = new FileDescription(fileName, stream),
            PublicId = publicId,
            Overwrite = false,
        };

        var result = await _cloudinary.UploadAsync(uploadParams, "raw", cancellationToken);

        if (result.Error is not null)
        {
            throw new InvalidOperationException(
                $"Cloudinary upload failed for store {storeId}: {result.Error.Message}");
        }

        if (result.SecureUrl is null)
        {
            throw new InvalidOperationException(
                $"Cloudinary upload for store {storeId} succeeded but returned no SecureUrl.");
        }

        return result.SecureUrl.ToString();
    }
}
