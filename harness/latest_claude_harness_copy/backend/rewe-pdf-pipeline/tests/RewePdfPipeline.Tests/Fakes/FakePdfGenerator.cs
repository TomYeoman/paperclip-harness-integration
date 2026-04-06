using RewePdfPipeline.Domain;
using RewePdfPipeline.Interfaces;

namespace RewePdfPipeline.Tests.Fakes;

public sealed class FakePdfGenerator : IPdfGenerator
{
    public StoreMetadata? LastStore { get; private set; }

    public byte[] GenerateTcsPdf(StoreMetadata store)
    {
        LastStore = store;
        // Minimal PDF marker bytes for testing — content verified via LastStore
        return System.Text.Encoding.UTF8.GetBytes($"%PDF-fake|{store.StoreName}|{store.StoreAddress}");
    }
}
