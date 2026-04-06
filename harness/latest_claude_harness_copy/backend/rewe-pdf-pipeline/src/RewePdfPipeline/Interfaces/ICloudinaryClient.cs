namespace RewePdfPipeline.Interfaces;

public interface ICloudinaryClient
{
    /// <summary>
    /// Uploads a PDF to Cloudinary using a versioned store-specific path.
    /// Returns the resulting public URL.
    /// </summary>
    Task<string> UploadPdfAsync(string storeId, byte[] pdfBytes, CancellationToken cancellationToken = default);
}
