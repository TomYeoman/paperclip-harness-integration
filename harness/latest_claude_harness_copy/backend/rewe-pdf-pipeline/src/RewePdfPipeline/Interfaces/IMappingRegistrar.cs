namespace RewePdfPipeline.Interfaces;

public interface IMappingRegistrar
{
    /// <summary>
    /// Registers the generated pdf_url for the store in the mapping data layer.
    /// </summary>
    Task RegisterPdfUrlAsync(string storeId, string pdfUrl, CancellationToken cancellationToken = default);
}
