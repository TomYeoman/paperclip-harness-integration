using ReweMappingService.Models;

namespace ReweMappingService.Services;

public class InMemoryStoreDocumentRepository : IStoreDocumentRepository
{
    private static readonly Dictionary<string, StoreDocument> Seed = new()
    {
        ["REWE_TEST_999"] = new StoreDocument(
            StoreId: "REWE_TEST_999",
            TcsUrl: "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/tcs.pdf",
            PrivacyUrl: "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/privacy.pdf",
            PdfUrl: "https://res.cloudinary.com/jet-rewe/image/upload/v20260301/rewe/REWE_TEST_999/tcs.pdf"
        )
    };

    public StoreDocument? FindByStoreId(string storeId)
    {
        Seed.TryGetValue(storeId, out var doc);
        return doc;
    }
}
