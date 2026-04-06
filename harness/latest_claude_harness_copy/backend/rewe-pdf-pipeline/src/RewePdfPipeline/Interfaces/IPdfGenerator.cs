using RewePdfPipeline.Domain;

namespace RewePdfPipeline.Interfaces;

public interface IPdfGenerator
{
    /// <summary>
    /// Generates a T&amp;C PDF with store_name and store_address injected.
    /// Returns raw PDF bytes.
    /// </summary>
    byte[] GenerateTcsPdf(StoreMetadata store);
}
